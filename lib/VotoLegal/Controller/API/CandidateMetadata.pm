package VotoLegal::Controller::API::CandidateMetadata;
use common::sense;
use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }


sub root : Chained('/api/root') : PathPart('candidate-metadata') : CaptureArgs(0) {
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
                        $twitter_profile = '@' . $twitter_profile
                    }

					+{
						name            => $c->name,
                        popular_name    => $c->popular_name,
                        slug            => $c->username,
                        picture         => $c->picture,
                        twitter_profile => $twitter_profile,
						party_acronym   => $c->party->acronym,
						party_name      => $c->party->name
					}
				} $c->stash->{collection}->search(
                    {
						-and => [
							'user.email'  => { 'NOT ILIKE' => '%eokoe%' },
							'user.email'  => { 'NOT ILIKE' => '%hernani@%' },
							'user.email'  => { 'NOT ILIKE' => '%appcivico%' },
							'user.email'  => { 'NOT ILIKE' => '%+%' },
							'me.name'     => { 'NOT ILIKE' => '%Thiago Rondon%' },
							'me.name'     => { 'NOT ILIKE' => '%Lucas Ansei%' },
							'me.name'     => { 'NOT ILIKE' => '%Hernani Mattos%' },
							'me.name'     => { 'NOT ILIKE' => '%Evelyn Perez%' },
							'me.name'     => { 'NOT ILIKE' => '%Edgard Lobo%' },
							'me.username' => { 'NOT ILIKE' => '%campanharede%' },
							'me.username' => { 'NOT ILIKE' => '%campanhapsol%' }
						  ]
                    },
                    { prefetch => [qw/ user /] }
                  )->all()
			],
			generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
		}
	);
}

__PACKAGE__->meta->make_immutable;

1;
