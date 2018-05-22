package VotoLegal::Controller::API3::PagSeguro;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api3/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('pagseguro') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::PaymentNotification');

    $c->stash->{pagseguro} = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID},
        merchant_key => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY},
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX},
        logger       => $c->log,
    );
}

sub callback : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub callback_POST {
    my ( $self, $c ) = @_;

    my $notification_code = $c->req->params->{notificationCode};
    die \[ 'notificationCode', 'missing' ] unless $notification_code;

    my $notify = $c->stash->{collection}->execute(
        $c,
        for  => "upsert",
        with => { notification_code => $notification_code }
    );

    if ( my $req = $c->stash->{pagseguro}->notification($notification_code) ) {
        my $status = $req->{status};

        my $transaction_code = $req->{code};
        die \['transaction_code', 'missing'] unless $transaction_code;

        my $payment = $c->model("DB::Payment")->search( { code => $transaction_code } )->next;
        die \['transaction_code', 'could not find payment with that transaction code'] unless $payment;

        my $candidate = $payment->candidate;

        if ( $status == 3 || $status == 4 ) {

            $candidate->update(
                {
                    payment_status => "paid",
                    status         => 'activated'
                }
            );
            $candidate->send_payment_approved_email();

            $payment->payment_logs->create( { status => 'captured' } );
        }
        elsif ( $status == 6 || $status == 7 ) {
            $payment->payment_logs->create( { status => 'failed' } );

            $candidate->send_payment_not_approved_email();
        }
        elsif ( $status == 2 ) {
            $payment->payment_logs->create( { status => 'analysis' } );

        }
    }

    return $self->status_ok( $c, entity => { success => 1 } );
}

sub callback_GET {
    my ( $self, $c ) = @_;

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
