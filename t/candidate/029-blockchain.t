use common::sense;
use FindBin qw($Bin);
use Digest::SHA qw/ sha256_hex /;

BEGIN {
    use lib "$Bin/../lib";
    $ENV{LR_CODE_JSON_FILE} = $Bin . '/../../lr_code.json';
}

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Aprovando o candidato.
    ok( my $candidate = $schema->resultset('Candidate')->search( { 'me.id' => $candidate_id } )->next, 'get candidate' );
    ok( $candidate->update( { status => 'activated' } ), 'activate candidate' );

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
      name   => 'edit candidate',
      params => {
        cnpj               => format_cnpj( random_cnpj() ),
        payment_gateway_id => 2,
        merchant_id        => fake_email->(),
        merchant_key       => random_string(32),
      },
    ;

    # Mockando doações.
    for my $i (1 .. 10) {
        my $donation = &mock_donation;
        $donation->update(
            {
                captured_at         => \"(NOW() - (ROUND(RANDOM() * 1440) || ' minutes')::interval)",
                decred_merkle_root  => sha256_hex(int($i % 3)),
                decred_capture_txid => sha256_hex(random_string(10)),
                dcrtime_timestamp   => \"(NOW() - (ROUND(RANDOM() * 1440) || ' minutes')::interval)",
            }
        );
    }

    subtest 'list donations' => sub {

        rest_get [ '/public-api/blockchain' ],
          name  => 'list',
          stash => 'blockchain_list',
        ;

        stash_test 'blockchain_list' => sub {
            my $res = shift;
            p $res;
        };
    };

    #rest_get [ '/public-api/donation/merkle_root' ],
    #  name  => 'list merkle root',
    #  stash => 'merkle_root',
    #;
 #
    #stash_test 'merkle_root' => sub {
    #    my $res = shift;
 #
    #    p $res;
    #};
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
