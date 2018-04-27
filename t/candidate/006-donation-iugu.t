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
                {
                    id   => 3,
                    name => 'Iugu'
                }
            ],
            'list payment gateways',
        );
    };

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

    my $fake_donation = fake_hash({
        method                       => 'credit_card',
        name                         => fake_name(),
        cpf                          => sub { random_cpf() },
        email                        => fake_email(),
        credit_card_token            => 'foobar',
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

    # rest_post "/api/candidate/$candidate_id/donate",
    #     name    => "not authorized",
    #     is_fail => 1,
    #     params  => {
    #         %{ $fake_donation->() },
    #         credit_card_number => "0000000000000002",
    #     },
    # ;
};

done_testing();