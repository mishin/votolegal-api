use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

plan skip_all => 'skip external service test';

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

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            payment_gateway_id => 2,
            merchant_id        => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID},
            merchant_key       => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY},
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

    # Obtendo a sessão do PagSeguro.
    rest_get "/api/candidate/$candidate_id/donate/session",
        name  => "get session",
        stash => 's1',
    ;

    stash_test 's1' => sub {
        my $res = shift;

        ok (
            $res->{id} =~ m{^[a-f0-9]{32}$},
            'get session'
        );
    };

    # TODO Reativar este teste.
    done_testing;
    exit 0;

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
            credit_card_token            => random_string(12),
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
            sender_hash                  => "faa2cfa1c37a1379576bba47b496037854369f6679b569d19b571ea3ac06b6ce",
        },
    ;

    stash_test 'd1' => sub {
        my $res = shift;

        is (
            $schema->resultset('Donation')->find($res->{id})->status,
            'created',
            "donation created",
        );
    };
};

done_testing();

