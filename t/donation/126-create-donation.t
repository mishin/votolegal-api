use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my ( $response, $donation_url );
my $schema = VotoLegal->model('DB');
my $cpf    = '46223869762';

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Aprovando o candidato.
    ok(
        $schema->resultset('Candidate')->find($candidate_id)->update(
            {
                status         => "activated",
                payment_status => "paid",
                is_published   => 1,
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

    $response = rest_post "/api2/donations",
      name   => "add donation",
      params => {
        generate_rand_donator_data_cc(),

        candidate_id                  => stash 'candidate.id',
        device_authorization_token_id => stash 'test_auth',
        payment_method                => 'credit_card',
        cpf                           => $cpf,
        amount                        => 3000,
      };
    my $id_donation_of_3k = $response->{donation}{id};

    set_current_donation $id_donation_of_3k;
    assert_current_step('credit_card_form');
    is messages2str $response, 'msg_add_credit_card', 'msg add credit card';
    is form2str $response,     'credit_card_token',   'need send credit_card_token to continue';

    $donation_url = "/api2/donations/" . $response->{donation}{id};
    &test_dup_value;

    $response = rest_post $donation_url,
      code   => 200,
      name   => 'tenta dar post sem enviar dados',
      params => { device_authorization_token_id => stash 'test_auth', };
    assert_current_step('credit_card_form');
    is messages2str $response, 'msg_invalid_cc_token msg_add_credit_card', 'error msg included';

    setup_sucess_mock_iugu;

    $response = rest_post $donation_url,
      code   => 200,
      params => {
        device_authorization_token_id => stash 'test_auth',
        credit_card_token             => 'A5B22CECDA5C48C7A9A7027295BFBD95',
        cc_hash                       => '123456'
      };

    assert_current_step('register_capture');
    is messages2str $response, 'msg_cc_authorized msg_cc_paid_message', 'msg de todos os passos';

    my $donation_stash = get_current_stash;
    is( $donation_stash->{cc_hash},           '7c4a8d09ca3762af61e59520943dc26494f8941b', 'hash saved ok' );
    is( $donation_stash->{credit_card_token}, 'A5B22CECDA5C48C7A9A7027295BFBD95',         'teokn saved ok' );

    $response = rest_get $donation_url,
      code   => 200,
      params => { device_authorization_token_id => stash 'test_auth', };
    is messages2str $response, 'msg_cc_paid_message', 'apenas msg final';
    inc_paid_at_seconds;
    &test_boleto;

    rest_get '/public-api/candidate-summary/' . stash 'candidate.id', code => 200, stash => 'res';

    stash_test 'res', sub {
        my ($me) = @_;
        is $me->{candidate}{people_donated},             2,    '2 doações';
        is $me->{candidate}{total_donated_by_votolegal}, 6500, '6500 recebidos';
    };

    $ENV{MAX_DONATIONS_ROWS} = 2;
    rest_get '/public-api/candidate-donations/' . stash 'candidate.id',
      code  => 200,
      stash => 'res',
      name  => 'list last donations';

    stash_test 'res', sub {
        my ($me) = @_;

        is $me->{has_more}, 0, 'end of page';
        is $me->{donations}[0]{amount}, 3500, 'amount ok';
        is $me->{donations}[1]{amount}, 3000, 'amount ok';
        is $me->{donations}[1]{id}, $id_donation_of_3k, 'last donation is the first (reverse order)';
    };

    subtest 'pagination tests' => sub {
        $ENV{MAX_DONATIONS_ROWS} = 1;
        rest_get '/public-api/candidate-donations/' . stash 'candidate.id',
          code  => 200,
          stash => 'res',
          name  => 'list last donations with MAX_DONATIONS_ROWS=1';

        my $next;
        stash_test 'res', sub {
            my ($me) = @_;

            is $me->{has_more}, 1, 'has second page';
            is $me->{donations}[0]{amount}, 3500, 'amount ok';

            $next = $me->{donations}[0]{_marker};
        };

        rest_get [ '/public-api/candidate-donations', stash 'candidate.id', $next ],
          code  => 200,
          stash => 'res',
          name  => 'list donations before ' . $next;
        stash_test 'res', sub {
            my ($me) = @_;

            is $me->{has_more}, 0, 'end of page';
            is $me->{donations}[0]{amount}, 3000, 'amount ok';

        };

    };

    rest_get [ '/public-api/candidate-donations/' . stash 'candidate.id', 'donators-name' ],
      code  => 200,
      stash => 'res';

    stash_test 'res', sub {
        my ($me) = @_;

        is @{ $me->{names} }, '2', '2 names';
    };

};

done_testing();

exit;

sub test_dup_value {

    db_transaction {
        rest_post "/api2/donations",
          name    => "add donation with same value",
          code    => 400,
          is_fail => 1,
          stash   => 'donation.duplicated',
          params  => {
            generate_rand_donator_data_cc(),

            candidate_id                  => stash 'candidate.id',
            device_authorization_token_id => stash 'test_auth',
            payment_method                => 'credit_card',
            cpf                           => $cpf,
            amount                        => 3000,
          };

        error_is 'donation.duplicated', 'donation_repeated';

    };

}

sub test_boleto {

    $response = rest_post "/api2/donations",
      name   => "add donation with boleto",
      params => {
        generate_rand_donator_data_boleto(),

        candidate_id                  => stash 'candidate.id',
        device_authorization_token_id => stash 'test_auth',
        payment_method                => 'boleto',

        cpf    => $cpf,
        amount => 3500,
      };
    $donation_url = "/api2/donations/" . $response->{donation}{id};
    set_current_donation $response->{donation}{id};
    is messages2str $response, 'msg_boleto_message', 'msg_boleto_message';
    is links2str $response,    'msg_boleto_link',    'there is a link';
    assert_current_step('waiting_boleto_payment');

    setup_sucess_mock_iugu_boleto_success;

    my $donation_stash = get_current_stash;
    is keys %$donation_stash, 0, 'nothing on stash';

    $response = rest_get $donation_url,
      name   => "get donation boleto",
      params => { device_authorization_token_id => stash 'test_auth', };

    is messages2str $response, 'msg_boleto_paid_message', 'msg_boleto_paid_message';

    assert_current_step('register_capture');

}
