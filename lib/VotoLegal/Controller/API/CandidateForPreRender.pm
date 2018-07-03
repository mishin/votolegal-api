package VotoLegal::Controller::API::CandidateForPreRender;
use common::sense;
use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }


sub root : Chained('/api/root') : PathPart('candidates-for-prerender') : CaptureArgs(0) {
	my ( $self, $c ) = @_;

	$c->stash->{collection} = $c->model('DB::Candidate')->search(
		{
			status       => 'activated',
			is_published => 1
		},
	);
}

sub base : Chained('root') : PathPart('') : CaptureArgs(0) { }

sub candidate : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }


sub candidate_GET {
	my ( $self, $c ) = @_;

	my $donations = 1;
	if (exists $c->req->params->{donations} ) {
		$donations = $c->req->params->{donations};
	}

	return $self->status_ok(
		$c,
		entity => {
			candidates   => [
				map {
					my $c = $_;

					my $twitter_url = $c->twitter_url;
					$twitter_url =~ m/^(http:\/\/)|(https:\/\/)?(www.)?twitter.com\/(\S{0,15})$/;

					my $twitter_profile = $4;

					if ( $twitter_profile !~ m/^@/ ) {
						$twitter_profile = '@' . $twitter_profile;
					}

					+{
						name            => $c->name,
						popular_name    => $c->popular_name,
						slug            => $c->username,
						picture         => $c->picture,
						twitter_profile => $twitter_profile,
						address_state   => $c->running_for_address_state ? $c->running_for_address_state : $c->address_state,
						office          => $c->office->name,

						# A implementação do avatar foi feita no dia 21/06/2018. Nem todos os candidatos estão
						# com essa coluna preenchida ainda.
						( $c->avatar ? ( avatar => $c->avatar ) : () )
					  }
				  } $c->stash->{collection}->search(
					undef,
					{ prefetch => [qw/ user candidate_donation_summary /] }
				  )->all()
			],
			generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
		}
	);
}

__PACKAGE__->meta->make_immutable;

1;
