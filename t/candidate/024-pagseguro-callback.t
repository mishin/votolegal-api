use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    my $name             = fake_name()->();
    my $popular_name     = fake_name()->();
    my $email            = fake_email()->();
    my $cpf              = random_cpf();
    my $address_state    = 'SP';
    my $address_city     = 'São Paulo';
    my $address_zipcode  = '01310-100';
    my $address_street   = 'Av. Paulista';
    my $address_district = 'Paraíso', my $address_house_number = 1 + int( rand(2000) );
    my $phone            = '(42)23423-4234';

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

    api_auth_as candidate_id => $candidate_id;

    rest_post "/api/candidate/$candidate_id/payment",
      name    => 'Payment without contract signature',
      is_fail => 1,
      code    => 400,
      ;

    create_candidate_contract_signature($candidate_id);

    my $fake_sender_hash       = '52578d5d3336ec7a43ff1dae4794d0c5625feddcc8fbc0e80bcb0cb46c9947d4';
    my $fake_credit_card_token = '1e358d39e26448dc8a28d0f1815f08c5';

    my $payment = $schema->resultset("Payment")->create(
        {
            candidate_id         => $candidate_id,
            method               => 'boleto',
            name                 => $name,
            email                => 'email@sandbox.pagseguro.com.br',
            sender_hash          => $fake_sender_hash,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone,
            code                 => 'foobar'
        }
    );

    ok ( $candidate->payment_status eq 'unpaid', 'payment status' );

    # Mockando callback
    rest_post "/api3/pagseguro",
        name => 'payment callback',
        code => 200,
        [
            notificationType => 'transaction',
            notificationCode => 'foobar'
        ]
    ;

    ok ( $candidate->discard_changes, 'candidate discard changes' );
    ok ( $candidate->payment_status eq 'paid', 'payment status' );
    is ( $schema->resultset("EmailQueue")->count, 3, 'expected email count' );
    is ( $schema->resultset("PaymentLog")->count, 1, 'expected payment log count' );

};

done_testing();