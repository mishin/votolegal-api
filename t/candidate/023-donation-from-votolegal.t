use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

my $candidate;
my $candidate_id;

db_transaction {

    $candidate    = create_candidate;
    $candidate_id = $candidate->{id};

    # Aprovando o candidato.
    ok(
        $schema->resultset('Candidate')->find($candidate_id)->update(
            {
                status         => "activated",
                payment_status => "paid",
            }
        ),
        'activate',
    );

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
      name   => 'edit candidate',
      params => {
        payment_gateway_id => 1,
        merchant_id        => fake_email->(),
        merchant_key       => random_string(32),
      },
      ;

    my $first_donation  = &mock_donation;
	inc_paid_at_seconds;
	&mock_donation;

    rest_get "/api/candidate/$candidate_id/votolegal-donations",
        name    => 'invalid order_by_created_at',
        is_fail => 1,
        code    => 400,
        [ order_by_created_at => 'foo' ]
    ;

    $ENV{MAX_DONATIONS_ROWS} = 2;
    rest_get "/api/candidate/$candidate_id/votolegal-donations",
        name  => 'get donations from voto legal',
        list  => 1,
        stash => 'get_donations',
		[ order_by_created_at => 'asc' ]
    ;

	subtest 'pagination tests' => sub {
		$ENV{MAX_DONATIONS_ROWS} = 1;
		rest_get "/api/candidate/$candidate_id/votolegal-donations",
		  code  => 200,
		  stash => 'res',
		  name  => 'list last donations with MAX_DONATIONS_ROWS=1';

		my $next;
		stash_test 'res', sub {
			my ($me) = @_;

			is $me->{has_more}, 1, 'has second page';
			is $me->{donations}[0]{amount}, '30,00', 'amount ok';

			$next = $me->{donations}[0]{_marker};
		};

		rest_get [ "/api/candidate/$candidate_id/votolegal-donations", $next ],
		  code  => 200,
		  stash => 'res',
		  name  => 'list donations before ' . $next;
		stash_test 'res', sub {
			my ($me) = @_;

			is $me->{has_more}, 0, 'end of page';
			is $me->{donations}[0]{amount}, '30,00', 'amount ok';

		};

	};
};

done_testing();

sub mock_donation {
    api_auth_as 'nobody';

    generate_device_token;
    set_current_dev_auth( stash 'test_auth' );

    my $cpf = random_cpf();

    my $response = rest_post "/api2/donations",
      name   => "add donation",
      params => {
        generate_rand_donator_data_cc(),
        candidate_id                  => stash 'candidate.id',
        device_authorization_token_id => stash 'test_auth',
        payment_method                => 'credit_card',
        cpf                           => $cpf,
        amount                        => 3000,
      };

    setup_sucess_mock_iugu;
    my $donation_id  = $response->{donation}{id};
    my $donation_url = "/api2/donations/" . $donation_id;

    $response = rest_post $donation_url,
      code   => 200,
      params => {
        device_authorization_token_id => stash 'test_auth',
        credit_card_token             => 'A5B22CECDA5C48C7A9A7027295BFBD95',
        cc_hash                       => '123456'
      };
    is( messages2str($response), 'msg_cc_authorized msg_cc_paid_message', 'msg de todos os passos' );

    ok( my $donation = $schema->resultset('VotolegalDonation')->find($donation_id), 'get donation' );

    return $donation;
}