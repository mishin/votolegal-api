package VotoLegal::Controller::API::Admin::PaymentDiscount;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/admin/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::PaymentDiscount');
}

sub base : Chained('root') : PathPart('payment_discount') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $discount = $c->stash->{collection}->execute(
        for  => 'create',
        with => $c->req->params
    );

    return $self->status_created(
        $c,
        location => $c->uri_for_action($c->action, $c->req->captures, $discount->id)->as_string,
        entity   => { id => $discount->id },
    );
}

sub list_GET {
    my ($self, $c) = @_;

    return $self->status_ok(
        $c,
        entity => {
            map {
                my $p = $_;

                {
                    id => $p->get_value('id'),
                    party_id =>

                }
            } $c->stash->collection->search(undef)->all()
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
