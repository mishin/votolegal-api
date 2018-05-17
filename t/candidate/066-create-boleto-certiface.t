use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

$ENV{CERTIFICATE_ENABLED} = 1;

#$ENV{CERTIFICATE_ENABLED} = 1;

use VotoLegal::Test::Further;

my ( $response, $donation_url );
my $schema = VotoLegal->model('DB');
my $cpf    = '15859607059';

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

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

    setup_mock_certiface;
    $response = rest_post "/api2/donations",
      name   => "add donation",
      params => {
        generate_rand_donator_data(),

        candidate_id                  => stash 'candidate.id',
        device_authorization_token_id => stash 'test_auth',
        payment_method                => 'boleto',
        cpf                           => $cpf,
        amount                        => 3000,
      };

    assert_current_step('boleto_authentication');
    is messages2str $response, 'msg_text_certiface', 'message ok';
    is $response->{ui}{messages}[1]{text}, 'msg_link_certiface', 'has link';

    do {
        rest_get '/api2/certiface2donation',
          code    => 400,
          is_fail => 1,
          stash   => 'test',
          params  => {
            device_authorization_token_id => stash 'test_auth',
            certiface_token               => '00000000-0000-4e0c-81db-53ddc14a44e0'
          };
        error_is 'test', 'donation-not-found';

        my $donation = rest_get '/api2/certiface2donation',
          code   => 200,
          params => {
            device_authorization_token_id => stash 'test_auth',
            certiface_token               => 'dd24700e-2855-4e0c-81db-53ddc14a44ec'
          };

        $donation_url = "/api2/donations/" . $donation->{donation_id};
    };

    # falhou no certiface
    db_transaction {
        setup_mock_certiface_fail;
        $response = rest_get $donation_url,
          code   => 200,
          params => { device_authorization_token_id => stash 'test_auth', };
        assert_current_step('certificate_refused');
        is messages2str $response, 'msg_certificate_refused',     'msg_certificate_refused';
        is buttons2str $response,  'btn_pay_with_cc-pay_with_cc', 'button to pay with credit card';

        my $token = $schema->resultset('CertifaceToken')->find('dd24700e-2855-4e0c-81db-53ddc14a44ec');

        is $token->fail_reasons, '["PROVA DE VIDA","IMAGEM [Posicionamento não frontal]","PROVA DE VIDA"]',
          'fail reasons';
        is $token->validated, 0, 'not validated';
        ok $token->response, 'response updated';

        # troca metodo para cartao
        $response = rest_post $donation_url,
          code   => 200,
          name   => 'diz que quer pagar com cartao entao',
          params => { device_authorization_token_id => stash 'test_auth', action_id => 'pay_with_cc' };
        assert_current_step('credit_card_form');
    };

    # sucesso no certiface
    db_transaction {

        setup_mock_certiface_success;
        setup_sucess_mock_iugu;

        $response = rest_get $donation_url,
          code   => 200,
          params => { device_authorization_token_id => stash 'test_auth', };

        assert_current_step('waiting_boleto_payment');
        is messages2str $response, 'msg_boleto_message', 'msg_certificate_refused';

    };

};

done_testing();

exit;

