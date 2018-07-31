package VotoLegal::Controller::API::Candidate::Payment;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

use JSON;
use XML::Hash::XS qw/ hash2xml xml2hash /;
use DateTime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::Payment');

    my $candidate = $c->stash->{candidate};

    if ( $candidate->user->has_signed_contract == 0 ) {
        $self->status_bad_request( $c, message => 'user did not sign contract' );
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

sub base : Chained('root') : PathPart('payment') : CaptureArgs(0) { }

sub payment : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub payment_POST {
    my ( $self, $c ) = @_;

    my $now = DateTime->now();

    if ( $E )

    my $gateway = $c->req->params->{payment_gateway} || 'iugu';
    die \['gateway', 'invalid'] unless $gateway =~ m/(iugu|pagseguro)/;

    my $candidate = $c->stash->{candidate};

    my $method = $c->req->params->{method};
    die \[ 'method', 'missing' ] unless $method;

    my $credit_card_token = $c->req->params->{credit_card_token};

    die \[ 'credit_card_token', 'missing' ]            if $method eq 'creditCard' && !$credit_card_token;
    die \[ 'credit_card_token', 'should not be sent' ] if $method eq 'boleto'     && $credit_card_token;

    my $payment = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => {
            %{ $c->req->params }, candidate_id => $c->stash->{candidate}->id
        }
    );

    my $payment_execution;
    if ($gateway eq 'iugu') {
        $payment_execution = $payment->create_and_capture_iugu_invoice( $credit_card_token );
    }
    else {
        $payment_execution = $payment->send_pagseguro_transaction( $credit_card_token, $c->log );
    }

    my ( $payment_link, $payment_code );
    if ( $gateway eq 'pagseguro' ) {
		if ( ( ref $payment_execution ne 'HASH' ) || ( !$payment_execution && !$payment_execution->{paymentLink} ) ) {

			# Criando entrada no log
			$c->model("DB::PaymentLog")->create(
				{
					payment_id => $payment->id,
					status     => 'failed'
				}
			);

			$c->stash->{candidate}->send_payment_not_approved_email();

			die \[ 'Pagseguro: ', $payment_execution ];
		}

		$candidate->send_payment_in_analysis_email();

		$c->model("DB::PaymentLog")->create(
			{
				payment_id => $payment->id,
				status     => 'analysis'
			}
		);

		$payment->update( { code => $payment_execution->{code} } );

        $payment_link = $payment_execution->{paymentLink};
        $payment_code = $payment_execution->{code};
    }
    else {
		if ( ( ref $payment_execution ne 'HASH' ) || ( !$payment_execution && !$payment_execution->{id} ) ) {

			# Criando entrada no log
			$c->model("DB::PaymentLog")->create(
				{
					payment_id => $payment->id,
					status     => 'failed'
				}
			);

			$c->stash->{candidate}->send_payment_not_approved_email();

			die 'invalid gateway response';
		}


        $payment_link = $payment_execution->{secure_url} unless $method eq 'creditCard';
        $payment_code = $payment_execution->{id};
    }

    return $self->status_ok(
        $c,
        entity => {
            url  => $payment_link,
            code => $payment_code
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
