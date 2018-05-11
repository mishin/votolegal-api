package VotoLegal::Controller::API::Candidate::Payment::Callback;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/payment/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('callback') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::PaymentNotification');

}

sub callback : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub callback_POST {
    my ( $self, $c ) = @_;

    my $notification_code = $c->req->params->{notificationCode};
    die \['notificationCode', 'missing'] unless $notification_code;

    my $notify = $c->stash->{collection}->execute(
        $c,
        for  => "upsert",
        with => { notification_code => $notification_code }
    );

    if ( my $req = $c->stash->{pagseguro}->notification($notification_code) ) {
        my $status = $req->{status};

        if ($status == 3 || $status == 4) {

            $c->stash->{candidate}->update( { payment_status => "paid" } );
            $c->stash->{candidate}->send_payment_approved_email();

            # Criando entrada no log
            my $payment = $c->model("DB::Payment")->search( { code => $req->{code} } )->next;
            $c->model("DB::PaymentLog")->create(
                {
                    payment_id => $payment->id,
                    status     => 'captured'
                }
            );

        }
        elsif ($status == 6 || $status == 7) {
            my $payment = $c->model("DB::Payment")->search( { code => $req->{code} } )->next;
            $c->model("DB::PaymentLog")->create(
                {
                    payment_id => $payment->id,
                    status     => 'failed'
                }
            );
            $c->stash->{candidate}->send_payment_not_approved_email();

        }
        elsif ($status == 2) {
            my $payment = $c->model("DB::Payment")->search( { code => $req->{code} } )->next;
            $c->model("DB::PaymentLog")->create(
                {
                    payment_id => $payment->id,
                    status     => 'analysis'
                }
            );
        }
    }

    return $self->status_ok( $c, entity => { success => 1 } );
}

sub callback_GET {
    my ($self, $c) = @_;

    return $self->status_ok(
        $c,
        entity => {
            success => 1
        }
    );
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
