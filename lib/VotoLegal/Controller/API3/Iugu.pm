package VotoLegal::Controller::API3::Iugu;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api3/base') : PathPart('') : CaptureArgs(0) { }


sub base : Chained('root') : PathPart('iugu') : CaptureArgs(0) {
	my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::Payment');

}

sub callback : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }


sub callback_POST {
	my ( $self, $c ) = @_;

	my $payment_id = $c->req->params->{ 'data[id]' };
    my $status     = $c->req->params->{ 'data[status]' };

    my $payment = $c->stash->{collection}->search( { code => $payment_id } )->next;
    die \['id', 'could not find payment with that id'] unless $payment;

    if ( $status eq 'paid' ) {

        $payment->candidate->update(
            {
                status         => 'activated',
                payment_status => 'paid'
            }
        );
        $payment->create_log_success;
    }
    elsif ( $status =~ m/^(expired|canceled)$/ ) {
        $payment->create_log_refused;
    }

    return $self->status_ok(
		$c,
		entity => {
			success => 1
		}
	);
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


__PACKAGE__->meta->make_immutable;

1;
