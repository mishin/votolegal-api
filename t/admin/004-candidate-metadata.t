use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

use Text::CSV;

my $schema = VotoLegal->model('DB');

db_transaction {

	my $name          = fake_name()->();
    my $username      = 'foobar';

	create_candidate(
		name          => $name,
        username      => $username
	);

	my $candidate_id = stash "candidate.id";
	my $candidate    = $schema->resultset("Candidate")->find($candidate_id);

	$candidate->update(
        {
            status       => 'activated',
            is_published => 1,
            twitter_url  => 'https://twitter.com/lucas_ansei'
        }
    );

	api_auth_as user_id => 1;

	rest_get "/api/admin/candidate-metadata",
	  name  => 'get candidates with metadata',
	  list  => 1,
	  stash => 'get_candidate_metadata';

	stash_test "get_candidate_metadata" => sub {
		my $res = shift;

        my $candidate_res = $res->{candidates}->[0];

		ok( exists( $candidate_res->{picture} ), 'picture param exists' );
		is( $candidate_res->{name},              $name,         'name' );
		is( $candidate_res->{slug},              $username,     'slug' );
		is( $candidate_res->{twitter_profile},   '@lucas_ansei', 'twitter profile' );
	}
};

done_testing();