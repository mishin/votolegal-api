package VotoLegal::Controller::API::Candidate::Payment;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('payment') : CaptureArgs(0) { }

sub payment : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub payment_POST {
    my ($self, $c) = @_;

    my $payment = $c->model('DB::Payment')->create({
        code         => $payment->{code},
        candidate_id => $c->stash->{candidate}->id,
        sender_hash  => $c->req->params->{senderHash},
        boleto_url   => $payment->{paymentLink},
    });

    $payment = $payment->send_pagseguro_transaction();

    if (!$payment && !$payment->{paymentLink}) {
        $self->status_bad_request($c, message => 'Invalid gateway response');
        $c->detach();
    }

    return $self->status_ok(
        $c,
        entity   => { url => $payment->{paymentLink} },
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
