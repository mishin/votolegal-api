use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

plan skip_all => 'Procob is deactivated for now';

my $schema = VotoLegal->model('DB');

my $candidate;
my $candidate_id;
my $cpf = random_cpf();

db_transaction {
    use_ok 'VotoLegal::Worker::Procob';

    my $worker = new_ok( 'VotoLegal::Worker::Procob', [ schema => $schema ] );

    ok( $worker->does('VotoLegal::Worker'), 'VotoLegal::Worker::Procob does VotoLegal::Worker' );

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

    db_transaction{
        &setup_mock_procob_success;
        ok( $worker->run_once(), 'run once' );

        my $procob_rs  = $schema->resultset("ProcobResult");
        my $procob_res = $procob_rs->search( { donor_cpf => $cpf } )->next;

        ok ( my $procob_res = $procob_rs->search( { donor_cpf => $cpf } )->next, 'procob result entry' );
        is ( $procob_rs->count,           1, 'one result found' );
        is ( $procob_res->is_dead_person, 0, 'boolean is false' );
        ok ( $donation = $donation->discard_changes, 'donation discard_changes' );
        is ( $donation->procob_tested, 1, 'donation is now procob tested' );
    };

    db_transaction{
        &setup_mock_procob_fail;
        ok( $worker->run_once(), 'run once' );

        my $procob_rs  = $schema->resultset("ProcobResult");
        my $procob_res = $procob_rs->search( { donor_cpf => $cpf } )->next;

        ok ( my $procob_res = $procob_rs->search( { donor_cpf => $cpf } )->next, 'procob result entry' );
        is ( $procob_rs->count,           1, 'one result found' );
        is ( $procob_res->is_dead_person, 1, 'boolean is true' );
        ok ( $donation = $donation->discard_changes, 'donation discard_changes' );
        is ( $donation->procob_tested, 1, 'donation is now procob tested' );
    };

};

done_testing();

sub mock_donation {
    api_auth_as 'nobody';

    generate_device_token;
    set_current_dev_auth( stash 'test_auth' );

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

    setup_success_mock_iugu_direct_charge_cc;
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