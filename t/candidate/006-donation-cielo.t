use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Aprovando o candidato.
    ok(
        $schema->resultset('Candidate')->find($candidate_id)->update({
            status         => "activated",
            payment_status => "paid",
        }),
        'activate',
    );

    # Listagem de payment_gateway.
    rest_get "/api/payment_gateway",
        name => "list payment gateways",
        stash => "pg1",
    ;

    stash_test 'pg1' => sub {
        my $res = shift;

        is_deeply(
            $res->{payment_gateway},
            [
                {
                    id   => 1,
                    name => "Cielo",
                },
                {
                    id   => 2,
                    name => "PagSeguro",
                },
            ],
            'list payment gateways',
        );
    };

    # TODO Reativar este teste.
    done_testing;
    exit 0;

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            payment_gateway_id => 1,
            merchant_id        => fake_email->(),
            merchant_key       => random_string(32),
        },
    ;

    # Listando as doações feitas para este candidato.
    api_auth_as candidate_id => stash 'candidate.id';
    rest_get "/api/candidate/$candidate_id/donate",
        name  => "listing donations",
        stash => "l1",
    ;

    stash_test 'l1' => sub {
        my $res = shift;

        is_deeply ($res->{donations}, [], 'no donations');
    };

    # Fazendo as doações.
    api_auth_as 'nobody';

    # A Cielo oferece alguns números de cartões de créditos que respondem exatamente o que queremos na sandbox.
    # Realizarei o teste com esses cartões.
    my $fake_donation = fake_hash({
        name                         => fake_name(),
        cpf                          => sub { random_cpf() },
        email                        => fake_email(),
        credit_card_name             => fake_name(),
        credit_card_validity         => fake_future_datetime("%Y%m"),
        credit_card_brand            => "visa",
        credit_card_cvv              => fake_int(100, 999),
        amount                       => fake_int(1000, 106400),
        address_district             => "Centro",
        birthdate                    => fake_past_datetime("%Y-%m-%d"),
        address_state                => fake_pick(qw(SP RJ MG RS PR)),
        address_city                 => "Iguape",
        billing_address_house_number => fake_int(1, 1000)->(),
        billing_address_district     => "Centro",
        address_street               => "Rua Tiradentes",
        billing_address_city         => "Iguape",
        billing_address_state        => "SP",
        address_zipcode              => "11920-000",
        billing_address_street       => "Rua Tiradentes",
        billing_address_zipcode      => "11920-000",
        address_house_number         => fake_int(1, 1000)->(),
        phone                        => fake_digits("##########")->(),
    });

    # Doação com cartões de créditos não autorizados.
    rest_post "/api/candidate/$candidate_id/donate",
        name    => "not authorized",
        is_fail => 1,
        params  => {
            %{ $fake_donation->() },
            credit_card_number => "0000000000000002",
        },
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "not authorized",
        is_fail => 1,
        params  => {
            %{ $fake_donation->() },
            credit_card_number => "0000000000000007",
        },
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "not authorized",
        is_fail => 1,
        params  => {
            %{ $fake_donation->() },
            credit_card_number => "0000000000000008",
        },
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "not authorized",
        is_fail => 1,
        params  => {
            %{ $fake_donation->() },
            credit_card_number => "0000000000000005",
        },
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "not authorized",
        is_fail => 1,
        params  => {
            %{ $fake_donation->() },
            credit_card_number => "0000000000000003",
        },
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "not authorized",
        is_fail => 1,
        params  => {
            %{ $fake_donation->() },
            credit_card_number => "0000000000000006",
        },
    ;

    # Autorizada.
    rest_post "/api/candidate/$candidate_id/donate",
        name    => "donate to candidate",
        stash   => 'd1',
        code    => 200,
        params  => {
            %{ $fake_donation->() },
            credit_card_number => "0000000000000001",
        },
    ;

    #stash_test 'd1' => sub {
    #    my $res = shift;

    #    is (
    #        $schema->resultset('Donation')->find($res->{id})->status,
    #        'captured',
    #        "donation captured",
    #    );
    #};
};

done_testing();

