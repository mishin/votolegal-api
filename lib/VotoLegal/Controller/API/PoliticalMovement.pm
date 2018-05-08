package VotoLegal::Controller::API::PoliticialMovement;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::PoliticalMovement');
}

sub base : Chained('root') : PathPart('political_movement') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    return $self->status_ok($c, entity => {
        political_movement => [
            map { { id => $_->id, name => $_->name } }
              $c->stash->{collection}->all()
        ]
    });
}

__PACKAGE__->meta->make_immutable;

1;
