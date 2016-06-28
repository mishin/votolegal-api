package VotoLegal::Controller::API::Candidate;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

use Crypt::PRNG qw(random_string);
use VotoLegal::Uploader;

has s3 => (
    is      => "ro",
    isa     => "VotoLegal::Uploader",
    default => sub { VotoLegal::Uploader->new() },
);

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

    # Essa Controller possui uma lógica diferente: algumas actions são públicas, e outras são restritas. O GET
    # do candidate, por exemplo, não deve retornar todos os dados (como CPF e email privado) se ele não estiver
    # logado. E as actions de PUT devem ser feitas somente por quem está logado. Para isso criei essa flag 'is_me'
    # onde eu verifico se o candidato é o usuário que está logado.
    $c->stash->{is_me} = 0;
    if (ref $c->user && ($c->user->id == $candidate->user_id)) {
        $c->stash->{is_me} = 1;
    }
}

sub candidate : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub candidate_GET {
    my ($self, $c) = @_;

    my $candidate = {
        party                      => { $c->stash->{candidate}->party->get_columns() },
        candidate_issue_priorities => [
            map { { $_->issue_priority->get_columns() } } $c->stash->{candidate}->candidate_issue_priorities->all
        ],
    };

    # Se o candidato for o que está logado, retornaremos mais colunas. Se não, escondemos alguns dados.
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

    my $picture ;
    if (my $upload = $c->req->upload('picture')) {
        $picture = $self->_upload_picture($upload, $c->stash->{candidate}->id);
    }

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
    my ($self, $upload, $id_candidate) = @_;

    return unless $upload;

    die \['file', 'empty file']    unless $upload->size > 0;
    die \['file', 'invalid image'] unless $upload->type =~ m{^image\/};

    my $path = join "/", "votolegal", random_string(2), random_string(3), DateTime->now->datetime, $id_candidate;

    my $url = $self->s3->upload({
        path => $path,
        file => $upload->tempname,
        type => $upload->type,
    });

    return $url->as_string;
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
