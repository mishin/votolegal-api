use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

my $candidate;
my $candidate_id;

db_transaction {
    use_ok 'VotoLegal::Worker::Blockchain';

    local $ENV{VOTOLEGAL_DCRTIME_API} = 'https://time-testnet.decred.org:59152';

    my $worker = new_ok( 'VotoLegal::Worker::Blockchain', [ schema => $schema ] );

    ok( $worker->does('VotoLegal::Worker'), 'VotoLegal::Worker::Blockchain does VotoLegal::Worker' );

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

    my $donation = &mock_donation;
    subtest 'when not anchored' => sub {

        ok( $worker->run_once(), 'run once' );

        ok( !defined( $donation->decred_merkle_root ),  'decred_merkle_root=undef' );
        ok( !defined( $donation->decred_capture_txid ), 'decred_capture_txid=undef' );
    };

    subtest 'when anchored' => sub {

        $donation->update(
            {
                decred_data_raw    => undef,
                decred_data_digest => '83e99c8f31692ce5910f55be085156451ce48524275119e10ebf3a5c17ff3a6d',
            }
        );

        ok( $worker->run_once(), 'run once' );

        $donation->discard_changes;

        like( $donation->decred_merkle_root,  qr/^[a-f0-9]{64}$/, 'decred_merkle_root'  );
        like( $donation->decred_capture_txid, qr/^[a-f0-9]{64}$/, 'decred_capture_txid' );
        ok( defined( $donation->decred_merkle_registered_at ) );
        ok( defined( $donation->decred_capture_registered_at ) );
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
