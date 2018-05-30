package VotoLegal::Controller::PublicAPI::CandidateSlugs;
use common::sense;
use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/publicapi/root') : PathPart('candidate-slugs') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate')->search(
        {
            status       => 'activated',
            #is_published => 1
        },
    );
}

sub base : Chained('root') : PathPart('') : CaptureArgs(0) { }

sub candidate : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub candidate_GET {
    my ( $self, $c ) = @_;

    return $self->status_ok(
        $c,
        entity => {
            candidates   => [
                map {
                    my $c = $_;

                    slug     => $c->username,
                    url_path => '/em/' . $c->username
                } $c->stash->{collection}->all()
            ],
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
