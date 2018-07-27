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

    # Não consigo testar a doação efetivamente com o PagSeguro porque o senderHash é gerado no
    # front-end. Então vou mockar algumas doações.
    for ( 1 .. 3 ) {
        &mock_donation;
    }

    # Obtendo a api_key do candidate.
    ok( my $candidate = $schema->resultset('Candidate')->find( stash 'candidate.id' ), 'candidate' );
    ok( my $api_key = $schema->resultset('UserSession')->search( { user_id => $candidate->user_id } )->next->api_key,
        'api_key', );

    rest_get "/api/candidate/$candidate_id/donate/download/csv?api_key=$api_key",
      name    => 'invalid order_by_created_at',
      is_fail => 1,
      code    => 400,
      [ order_by_created_at => 'foo' ];

    # Enviando a request.
    my $req = request("/api/candidate/$candidate_id/donate/download/csv?api_key=$api_key");

    ok( $req->is_success(), 'download' );
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

    setup_success_mock_iugu_direct_charge_cc    ;
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
