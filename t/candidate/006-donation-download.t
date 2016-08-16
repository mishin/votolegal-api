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
    api_auth_as user_id => 1;
    rest_put "/api/admin/candidate/$candidate_id/activate",
        name  => 'activate candidate',
        code  => 200,
    ;

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            payment_gateway_id => 2,
            merchant_id        => VotoLegal->config->{pagseguro}->{sandbox}->{merchant_id},
            merchant_key       => VotoLegal->config->{pagseguro}->{sandbox}->{merchant_key},
            receipt_min        => 10_000,
            receipt_max        => 10_006,
        },
    ;

    # Não consigo testar a doação efetivamente com o PagSeguro porque o senderHash é gerado no
    # front-end. Então vou mockar algumas doações.
    for ( 1 .. 15 ) {
        $schema->resultset("Donation")->create({
            id                           => md5_hex($_),
            candidate_id                 => $candidate_id,
            name                         => fake_name()->(),
            email                        => fake_email()->(),
            cpf                          => random_cpf(),
            phone                        => fake_digits("##########")->(),
            amount                       => 500,
            birthdate                    => "1992-01-01",
            receipt_id                   => $_,
            ip_address                   => "127.0.0.1",
            address_state                => "SP",
            address_city                 => "Iguape",
            address_district             => "Centro",
            address_zipcode              => "11920-000",
            address_street               => "Rua Tiradentes",
            address_house_number         => 123,
            billing_address_street       => "Rua Tiradentes",
            billing_address_house_number => 123,
            billing_address_district     => "Centro",
            billing_address_zipcode      => "11920-000",
            billing_address_city         => "Iguape",
            billing_address_state        => "SP",
            status                       => "captured",
        });
    }

    rest_get "/api/candidate/$candidate_id/donate/download",
        name  => "download as csv",
        stash => "d1",
        params => {
            hours => 3,
        },
    ;

};

done_testing();

