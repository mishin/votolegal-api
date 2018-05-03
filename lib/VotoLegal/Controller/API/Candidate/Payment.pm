package VotoLegal::Controller::API::Candidate::Payment;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Payment');

    my $candidate = $c->stash->{candidate};

    if ($candidate->user->has_signed_contract == 0) {
        $self->status_bad_request($c, message => 'user did not sign contract');
        $c->detach();
    }

    $c->stash->{pagseguro} = my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID},
        merchant_key => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY},
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX},
        logger       => $c->log,
    );
}

sub base : Chained('root') : PathPart('payment') : CaptureArgs(0) {}

sub payment : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub payment_POST {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{candidate};

    my $method = $c->req->params->{method};
    die \['method', 'missing'] unless $method;

    my $credit_card_token = $c->req->params->{credit_card_token};

    die \['credit_card_token', 'missing'] if $method eq 'creditCard' && !$credit_card_token;
    die \['credit_card_token', 'should not be sent'] if $method eq 'boleto' && $credit_card_token;

    my $payment = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => {
            %{$c->req->params},
            candidate_id => $c->stash->{candidate}->id
        }
    );

    my $payment_execution = $payment->send_pagseguro_transaction($credit_card_token, $c->log);

    $candidate->send_payment_in_analysis_email();

    if (!$payment_execution && !$payment_execution->{paymentLink}) {
        $self->status_bad_request($c, message => 'Invalid gateway response');

        # Criando entrada no log
        $c->model("DB::PaymentLog")->create(
            {
                payment_id => $payment->id,
                status     => 'failed'
            }
        );

        $c->detach();
    }

    $payment->update( { code => $payment_execution->{code} } );

    return $self->status_ok(
        $c,
        entity => {
            url  => $payment_execution->{paymentLink},
            code => $payment_execution->{code}
        },
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
