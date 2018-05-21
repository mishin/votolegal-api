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
    for ( 1 .. 15 ) {
        $schema->resultset("Donation")->create(
            {
                id                           => md5_hex($_),
                candidate_id                 => $candidate_id,
                name                         => fake_name()->(),
                email                        => fake_email()->(),
                cpf                          => random_cpf(),
                phone                        => fake_digits("##########")->(),
                amount                       => fake_int( 1000, 10000 )->(),
                birthdate                    => "1992-01-01",
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
                captured_at                  => \'now()',
                by_votolegal                 => "t",
                donation_type_id             => 1,
                payment_gateway_id           => 1,
            }
        );
    }

    # Obtendo a api_key do candidate.
    ok( my $candidate = $schema->resultset('Candidate')->find( stash 'candidate.id' ), 'candidate' );
    ok( my $api_key = $schema->resultset('UserSession')->search( { user_id => $candidate->user_id } )->next->api_key,
        'api_key', );

    # Enviando a request.
    my $req = request("/api/candidate/$candidate_id/donate/download/csv?api_key=$api_key");
    ok( $req->is_success(), 'download' );
};

done_testing();

