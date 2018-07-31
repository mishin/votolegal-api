use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

use Text::CSV;

my $schema = VotoLegal->model('DB');

db_transaction {

    my $email            = fake_email()->();
    my $name             = fake_name()->();
    my $party_id         = 7;
    my $office_id        = fake_int( 4, 8 )->();
    my $cpf              = random_cpf();
    my $address_state    = 'SP';
    my $address_city     = 'São Paulo';
    my $address_zipcode  = '01310-100';
    my $address_street   = 'Av. Paulista';
    my $address_district = 'Paraíso', my $address_house_number = 1 + int( rand(2000) );
    my $phone            = '(42)23423-4234';

    create_candidate(
        email                => $email,
        name                 => $name,
        username             => 'foobar',
        party_id             => $party_id,
        cpf                  => $cpf,
        office_id            => $office_id,
        address_state        => $address_state,
        address_city         => $address_city,
        address_zipcode      => $address_zipcode,
        address_street       => $address_street,
        address_district     => $address_district,
        address_house_number => $address_house_number,
    );

    my $candidate_id = stash "candidate.id";
    my $candidate    = $schema->resultset("Candidate")->find($candidate_id);

    api_auth_as candidate_id => $candidate_id;

    create_candidate_contract_signature($candidate_id);

    api_auth_as user_id => 1;

    rest_get "/api/admin/candidate-with-related-data",
      name  => 'get candidate data for admin',
      list  => 1,
      stash => 'get_candidate';

    stash_test "get_candidate" => sub {
        my $res = shift;

        is( $res->{candidates}->[0]->{'status da conta'},   'não criou pagamento',            'payment status' );
        is( $res->{candidates}->[0]->{'pagina publicada'},  'DESABILITADO',                   'publish string' );
        is( $res->{candidates}->[0]->{'url'},               'www.votolegal.com.br/em/foobar', 'url' );
        is( $res->{candidates}->[0]->{'metodo'},            '0',                              'payment method' );
        is( $res->{candidates}->[0]->{'nome do candidato'}, $name,                            'nome' );
        is( $res->{candidates}->[0]->{'cpf'},               $cpf,                             'cpf' );
        is( $res->{candidates}->[0]->{'nome do pagamento'}, '0',                              'nome do pagamento' );
        is( $res->{candidates}->[0]->{'telefone'},          '0',                              'telefone' );
        is( $res->{candidates}->[0]->{'estado'},            $address_state,                   'estado' );
        is( $res->{candidates}->[0]->{'cidade'},            $address_city,                    'cidade' );
        is( $res->{candidates}->[0]->{'cep'},               $address_zipcode,                 'cep' );
        is( $res->{candidates}->[0]->{'rua'},               $address_street,                  'rua' );
        is( $res->{candidates}->[0]->{'numero'},            $address_house_number,            'número' );
        is( $res->{candidates}->[0]->{'valor bruto'},       '0',                              'valor bruto' );
        is( $res->{candidates}->[0]->{'taxa'},              '0',                              'taxas' );
        is( $res->{candidates}->[0]->{'valor liquido'},     '0',                              'valor líquido' );
    };

    my $fake_sender_hash       = '52578d5d3336ec7a43ff1dae4794d0c5625feddcc8fbc0e80bcb0cb46c9947d4';
    my $fake_credit_card_token = '1e358d39e26448dc8a28d0f1815f08c5';

    my $payment = $schema->resultset("Payment")->create(
        {
            candidate_id         => $candidate_id,
            method               => 'boleto',
            sender_hash          => $fake_sender_hash,
            email                => $email,
            name                 => $name,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone
        }
    );

    $candidate->update( { payment_status => 'paid' } );

    rest_get "/api/admin/candidate-with-related-data",
      name  => 'get candidate data for admin',
      list  => 1,
      stash => 'get_candidate';

    stash_test "get_candidate" => sub {
        my $res = shift;

        is( $res->{candidates}->[0]->{'status da conta'},   'pagamento aprovado',             'payment status' );
        is( $res->{candidates}->[0]->{'pagina publicada'},  'DESABILITADO',                   'publish string' );
        is( $res->{candidates}->[0]->{'url'},               'www.votolegal.com.br/em/foobar', 'url' );
        is( $res->{candidates}->[0]->{'metodo'},            'boleto',                         'payment method' );
        is( $res->{candidates}->[0]->{'nome do candidato'}, $name,                            'nome' );
        is( $res->{candidates}->[0]->{'cpf'},               $cpf,                             'cpf' );
        is( $res->{candidates}->[0]->{'nome do pagamento'}, $name,                            'nome do pagamento' );
        is( $res->{candidates}->[0]->{'telefone'},          $phone,                           'telefone' );
        is( $res->{candidates}->[0]->{'estado'},            $address_state,                   'estado' );
        is( $res->{candidates}->[0]->{'cidade'},            $address_city,                    'cidade' );
        is( $res->{candidates}->[0]->{'cep'},               $address_zipcode,                 'cep' );
        is( $res->{candidates}->[0]->{'rua'},               $address_street,                  'rua' );
        is( $res->{candidates}->[0]->{'numero'},            $address_house_number,            'número' );
        # is( $res->{candidates}->[0]->{'valor bruto'},       10,                               'valor bruto' );
        # is( $res->{candidates}->[0]->{'taxa'},              3,                                'taxas' );
        # is( $res->{candidates}->[0]->{'valor liquido'},     7,                                'valor líquido' );
    };
};

done_testing();

