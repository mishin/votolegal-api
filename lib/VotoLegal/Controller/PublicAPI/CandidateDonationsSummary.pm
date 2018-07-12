package VotoLegal::Controller::PublicAPI::CandidateDonationsSummary;
use common::sense;
use Moose;
use namespace::autoclean;
use DateTime;
use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }


sub root : Chained('/publicapi/root') : PathPart('candidate-donations-summary') : CaptureArgs(0) {
	my ( $self, $c ) = @_;

	$c->stash->{collection} = $c->model('DB::Candidate')->search( { status => 'activated' } );
}

sub base : Chained('root') : PathPart('') : CaptureArgs(0) { }


sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
	my ( $self, $c, $args ) = @_;

	# Quando o parâmetro é inteiramente numérico, o buscamos como id.
	# Quando não é, pesquisamos pelo 'slug'.
	my $candidate;
	if ( $args =~ m{^[0-9]{1,6}$} ) {
		$candidate = $c->stash->{collection}->find($args);
	}else {
		$candidate = $c->stash->{collection}->search( { 'me.username' => $args } )->next;
	}

	if ( !$candidate ) {
		$self->status_not_found( $c, message => 'Candidate not found' );
		$c->detach();
	}

	$c->stash->{candidate} = $candidate;
}

sub donate : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }


sub donate_GET {
	my ( $self, $c ) = @_;

    my $candidate = $c->stash->{candidate};
    my $summary   = $candidate->candidate_donation_summary;

    my $raising_goal = $candidate->raising_goal;

	if ( $raising_goal ) {
		$raising_goal *= 100;
	}
    else {
		$raising_goal = 100000;
	}

	return $self->status_ok(
		$c,
		entity => {
            candidate => {
				raising_goal               => $raising_goal,
				total_donated_by_votolegal => $summary->amount_donation_by_votolegal,
				count_donated_by_votolegal => $summary->count_donation_by_votolegal,
                generated_at               => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
            }
		}
	);
}

__PACKAGE__->meta->make_immutable;

1;
