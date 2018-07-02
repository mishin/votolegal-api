package VotoLegal::API::Controller::Candidate::ServiceDonation;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
	my ( $self, $c ) = @_;

	$c->stash->{collection} = $c->model("DB::CandidateServiceDonation");
}

sub base : Chained('root') : PathPart('service') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ( $self, $c ) = @_;

    my $service = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => $c->req->params
    );

	return $self->status_created(
		$c,
		location => $c->uri_for_action( $c->action, $c->req->captures, $service->id )->as_string,
		entity => { id => $service->id },
	);
}

__PACKAGE__->meta->make_immutable;

1;