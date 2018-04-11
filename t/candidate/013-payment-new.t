use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    my $name                 = fake_name()->();
    my $popular_name         = fake_name()->();
    my $email                = fake_email()->();
    my $cpf                  = random_cpf(),
    my $address_state        = 'SP';
    my $address_city         = 'São Paulo';
    my $address_zipcode      = '01310-100';
    my $address_street       = 'Av. Paulista';
    my $address_house_number = 1 + int(rand(2000));

    create_candidate(
        name                 => $name,
        popular_name         => $popular_name,
        email                => $email,
        cpf                  => $cpf,
        address_state        => $address_state,
        address_city         => $address_city,
        address_zipcode      => $address_zipcode,
        address_street       => $address_street,
        address_house_number => $address_house_number,
    );
    my $candidate_id = stash "candidate.id";
    my $candidate    = $schema->resultset("Candidate")->find($candidate_id);

    subtest 'candidate information objects' => sub {

        is_deeply(
            $candidate->get_address_data(),
            {
                state      => $address_state,
                city       => $address_city,
                postalCode => $address_zipcode,
                street     => $address_street,
                number     => $address_house_number,
                complement => ''
            },
            'candidate address data for PagSeguro'
        );

    };

    api_auth_as candidate_id => $candidate_id;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'Payment without contract signature',
        is_fail => 1,
        code    => 400,
    ;

    create_candidate_contract_signature($candidate_id);

    rest_get "/api/candidate/$candidate_id/payment/session",
        name    => "get session when not activated",
        stash   => 's1'
    ;

    my $fake_sender_hash       = '52578d5d3336ec7a43ff1dae4794d0c5625feddcc8fbc0e80bcb0cb46c9947d4';
    my $fake_credit_card_token = '1e358d39e26448dc8a28d0f1815f08c5';

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment without method',
        is_fail => 1,
        code    => 400,
        [
            sender_hash       => $fake_sender_hash,
            credit_card_token => $fake_credit_card_token
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment without sender_hash',
        is_fail => 1,
        code    => 400,
        [
            method            => 'creditCard',
            credit_card_token => $fake_credit_card_token
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment with invalid method',
        is_fail => 1,
        code    => 400,
        [
            method      => 'foobar',
            sender_hash => $fake_sender_hash,
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment with boleto method but with credit_card_token',
        is_fail => 1,
        code    => 400,
        [
            method            => 'boleto',
            sender_hash       => $fake_sender_hash,
            credit_card_token => $fake_credit_card_token
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment with creditCard method but without credit_card_token',
        is_fail => 1,
        code    => 400,
        [
            method            => 'creditCard',
            sender_hash       => $fake_sender_hash,
        ]
    ;

    # Não tem como gerar uma sender hash pelo backend apenas no front.
};

done_testing();