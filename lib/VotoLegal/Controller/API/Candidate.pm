package VotoLegal::Controller::API::Candidate;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

use File::MimeInfo;
use VotoLegal::Uploader;
use Crypt::PRNG qw(random_string);

has uploader => (
    is      => "ro",
    isa     => "VotoLegal::Uploader",
    default => sub { VotoLegal::Uploader->new() },
);

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    # Configuracoes do uploader.
    $self->uploader->access_key($c->config->{amazon_s3}->{access_key});
    $self->uploader->secret_key($c->config->{amazon_s3}->{secret_key});
    $self->uploader->media_bucket($c->config->{amazon_s3}->{media_bucket});

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
    my ($self, $c, $args) = @_;

    # Quando o parâmetro é inteiramente numérico, o buscamos como id.
    # Quando não é, pesquisamos pelo 'slug'.
    my $candidate;
    if ($args =~ m{^\d+$}) {
        $candidate = $c->stash->{collection}->find($args);
    }
    else {
        $candidate = $c->stash->{collection}->search({ 'me.username' => $args })->next;
    }

    if (!$candidate) {
        $self->status_not_found($c, message => 'Candidate not found');
        $c->detach();
    }

    $c->stash->{candidate} = $candidate;

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
            map { $_ => $c->stash->{candidate}->$_ } qw(
              id name popular_name status reelection party_id office_id status username picture
              video_url facebook_url twitter_url website_url summary biography instagram_url cnpj
              raising_goal public_email spending_spreadsheet address_city address_state
            )
        };
    }

    $candidate->{party_fund}                  = $c->stash->{candidate}->party_fund();
    $candidate->{total_donated}               = $c->stash->{candidate}->total_donated();
    $candidate->{people_donated}              = $c->stash->{candidate}->people_donated();
    $candidate->{people_donated_by_votolegal} = $c->stash->{candidate}->people_donated_by_votolegal();

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
    if (my $upload = $c->req->upload("picture")) {
        $picture = $self->_upload_picture($upload);
    }

    my $spending_spreadsheet ;
    if (my $upload = $c->req->upload("spending_spreadsheet")) {
        $spending_spreadsheet = $self->_upload_spreadsheet($upload);
    }

    # O Data::Verifier ignora strings "" e as seta como undef. :(
    for (keys %{ $c->req->params }) {
        if ($c->req->params->{$_} eq "") {
            $c->req->params->{$_} = "_SET_NULL_";
        }
    }

    my $candidate = $c->stash->{candidate}->execute(
        $c,
        for => 'update',
        with => {
            %{ $c->req->params },
            picture              => $picture,
            spending_spreadsheet => $spending_spreadsheet,
            roles                => [ $c->user->roles ],
        }
    );

    return $self->status_accepted($c, entity => { id => $candidate->id });
}

sub _upload_picture {
    my ($self, $upload) = @_;

    my $mimetype = mimetype($upload->tempname);

    die \['picture', 'empty file']    unless $upload->size > 0;
    die \['picture', 'invalid image'] unless $mimetype =~ m{^image\/};

    my $path = join "/", "votolegal", "picture", random_string(3), DateTime->now->epoch, $upload->tempname;

    my $url = $self->uploader->upload({
        path => $path,
        file => $upload->tempname,
        type => $mimetype,
    });

    return $url->as_string;
}

sub _upload_spreadsheet {
    my ($self, $upload) = @_;

    my $mimetype = mimetype($upload->tempname);

    die \['spending_spreadsheet', 'empty file']   unless $upload->size > 0;
    die \['spending_spreadsheet', 'invalid file'] unless $mimetype =~ m{^(text\/|application\/vnd\.)};

    my $path = join "/", "votolegal", "spreadsheet", random_string(3), DateTime->now->epoch, $upload->tempname;

    my $url = $self->uploader->upload({
        path => $path,
        file => $upload->tempname,
        type => $mimetype,
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
