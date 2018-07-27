use common::sense;
use FindBin qw($Bin);

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
    api_auth_as user_id => 1;
    rest_put "/api/admin/candidate/$candidate_id/activate",
      name => 'activate candidate',
      code => 200,
    ;

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

    my $donation = &mock_donation;

    like( my $digest = $donation->get_column('decred_data_digest'), qr/^[a-f0-9]{64}$/, 'digest' );

    rest_get [ '/public-api/donation/digest', $digest ],
        name  => 'get donation',
        stash => 'donation',
    ;

    stash_test 'donation' => sub {
        my $res = shift;

        is( ref $res->{donation}->{candidate},           'HASH', 'candidate' );
        is( ref $res->{donation}->{candidate}->{party},  'HASH', 'party'     );
        is( ref $res->{donation}->{candidate}->{office}, 'HASH', 'office'    );

        is( $res->{donation}->{amount}, 3000, 'amount=3000' );
        ok( defined $res->{donation}->{payment_method_human}, 'payment method' );

        like( $res->{donation}->{git_hash}, qr/^[a-f0-9]{40}$/, 'git hash' );
        like( $res->{donation}->{git_url},  qr/^https:\/\/github\.com\/AppCivico/, 'git url' );
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
