package VotoLegal::Controller::API::Candidate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Candidate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate')->search(
        undef,
        {
            prefetch => [
                'party',
                { 'candidate_issue_priorities' => 'issue_priority' },
            ],
        },
    );
}

sub base : Chained('root') : PathPart('candidate') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $candidate_id) = @_;

    my $candidate = $c->stash->{collection}->search({ 'me.id' => $candidate_id })->next;
    if ($candidate) {
        $c->stash->{candidate} = $candidate;
    }
    else {
        $self->status_bad_request($c, message => 'Candidate not found');
        $c->detach();
    }

    $c->stash->{is_me} = 0;
    if (ref $c->user && ($c->user->id == $candidate->user_id)) {
        $c->stash->{is_me} = 1;
    }
}

sub candidate : Chained('object') : PathPart('') : ActionClass('REST') { }

sub candidate_GET {
    my ($self, $c) = @_;

    # Se o candidato for o que está logado, retornaremos mais colunas. Se não, escondemos alguns dados.
    my $candidate = {
        party                      => { $c->stash->{candidate}->party->get_columns() },
        candidate_issue_priorities => [
            map { { $_->issue_priority->get_columns() } } $c->stash->{candidate}->candidate_issue_priorities->all
        ],
    };

    if ($c->stash->{is_me}) {
        $candidate = {
            %{$candidate},
            $c->stash->{candidate}->get_columns(),
        };
    }
    else {
        $candidate = {
            %{$candidate},
            map { $_ => $c->stash->{candidate}->$_ }
              qw(id name popular_name status reelection party_id office_id address_city address_state address_street address_house_number address_complement address_zipcode username)
        };
    }

    return $self->status_ok($c, entity => {
        candidate => $candidate,
    });
}

sub candidate_PUT {
    my ($self, $c) = @_;

    # Somente pessoas logadas podem editar.
    $c->forward("/api/logged");

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    my $picture = $self->_upload_picture($c->req->upload('file'));

    my $candidate = $c->stash->{candidate}->execute(
        $c,
        for => 'update',
        with => {
            %{ $c->req->params },
            picture => $picture,
            roles   => [ $c->user->roles ],
        }
    );

    return $self->status_accepted($c, entity => { id => $candidate->id });
}

sub _upload_picture {
    my ($self, $upload) = @_;

    return unless $upload;

    die \['file', 'empty file']    unless $upload->size > 0;
    die \['file', 'invalid image'] unless $upload->type =~ m{^image\/};

    # TODO Implementar o upload na Amazon S3.
    return "https://avatars0.githubusercontent.com/u/711681?v=3&s=460";
}

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
