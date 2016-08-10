package VotoLegal::Controller::API::Candidate::Payment::Callback;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/payment/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('callback') : CaptureArgs(0) { }

sub callback : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub callback_POST {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        notificationCode => {
            type     => "Str",
            required => 1,
        },
        notificationType => {
            type     => "Str",
            required => 1,
        },
    );

    my $payment_notification_rs = $c->model('DB::PaymentNotification');

    # Buscando uma notificação com esse id.
    my $notify = $payment_notification_rs->search({
        notification_code => $c->req->params->{notificationCode},
        notification_type => $c->req->params->{notificationType},
    })->next;

    # Se não encontrar, criamos esse registro no banco.
    if (!$notify) {
        $notify = $payment_notification_rs->create({
            notification_code => $c->req->params->{notificationCode},
            notification_type => $c->req->params->{notificationType},
        });
    }

    if (my $res = $c->stash->{collection}->getNotification($notify)) {
        if ($res->{reference} == $c->stash->{candidate}->id) {
            $c->stash->{candidate}->update({ payment_status => "paid" });
        }
    }

    return $self->status_ok($c, entity => { success => 1 });
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
