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

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            payment_gateway_id => 1,
            merchant_id        => "1006993069",
            merchant_key       => "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3",
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

    # Fazendo uma doação.
    api_auth_as 'nobody';
    rest_post "/api/candidate/$candidate_id/donate",
        name    => "donate to candidate",
        stash   => 'd1',
        code    => 200,
        params  => {
            name                         => fake_name()->(),
            cpf                          => random_cpf(),
            email                        => fake_email()->(),
            credit_card_name             => "JUNIOR MORAES",
            credit_card_validity         => "201801",
            credit_card_number           => "6362970000457013",
            credit_card_brand            => "elo",
            amount                       => 1000,
            address_district             => "Centro",
            birthdate                    => "1992-05-02",
            address_state                => "SP",
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
        },
    ;

    stash_test 'd1' => sub {
        my $res = shift;

        is (
            $schema->resultset('Donation')->find($res->{id})->status,
            'captured',
            "donation captured",
        );
    };
};

done_testing();

