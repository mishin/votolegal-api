use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    #use_ok 'VotoLegal::Worker::Blockchaind';

    #my $worker = new_ok('VotoLegal::Worker::Blockchaind', [ schema => $schema ]);

    #ok( $worker->does('VotoLegal::Worker'), 'VotoLegal::Worker::Blockchaind does VotoLegal::Worker' );

    subtest 'create donation' => sub {

        my $candidate = create_candidate;
        my $candidate_id = $candidate->{id};

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

        api_auth_as 'nobody';

        generate_device_token;
        set_current_dev_auth( stash 'test_auth' );

        my $cpf = '46223869762';

        my $response = rest_post "/api2/donations",
        name   => "add donation",
        params => {
            generate_rand_donator_data(),
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
    };

    #ok( $worker->run_once(), 'run once' );
};

done_testing();

