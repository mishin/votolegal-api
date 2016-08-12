use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

db_transaction {
    create_candidate;
    my $id_candidate = stash 'candidate.id';

    # Aprovando o candidato.
    api_auth_as user_id => 1;
    rest_put "/api/admin/candidate/$id_candidate/activate",
        name  => 'activate candidate',
        code  => 200,
    ;

    # Preenchendo os campos de pagamento.
    api_auth_as candidate_id => $id_candidate;
    rest_put "/api/candidate/$id_candidate",
        name   => 'edit candidate',
        params => {
            payment_gateway_id => 1,
            merchant_id        => "1006993069",
            merchant_key       => "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3",
            receipt_min        => 0,
            receipt_max        => 10,
        },
    ;

    # Adicionando quatro projetos.
    my @id_projects = ();
    for (1 .. 4) {
        rest_post "/api/candidate/${id_candidate}/projects",
            name   => "adding project",
            stash  => "project",
            params => {
                title => "Project $_",
                scope => lorem_paragraphs(),
            },
        ;

        stash_test 'project' => sub { push @id_projects, $_[0]->{id} };
    }

    # Fazendo uma doação.
    api_auth_as 'nobody';
    rest_post "/api/candidate/$id_candidate/donate",
        name    => "donate to candidate",
        stash   => 'donate',
        code    => 200,
        params  => {
            name                         => fake_name()->(),
            cpf                          => random_cpf(),
            email                        => fake_email()->(),
            phone                        => fake_digits("###########")->(),
            birthdate                    => "1992-05-02",
            address_street               => "Rua Tiradentes",
            address_house_number         => "123",
            address_district             => "Centro",
            address_zipcode              => "11920-000",
            address_city                 => "Iguape",
            address_state                => "SP",
            amount                       => 100,
            sender_hash                  => random_string(6),
            credit_card_token            => random_string(12),
            billing_address_street       => "Rua Tiradentes",
            billing_address_house_number => "123",
            billing_address_complement   => "Apto 1",
            billing_address_district     => "Centro",
            billing_address_zipcode      => "11920-000",
            billing_address_city         => "Iguape",
            billing_address_state        => "SP",
            credit_card_name             => "JUNIOR MORAES",
        },
    ;

    my $id_donation ;
    stash_test 'donate' => sub { $id_donation = $_[0]->{id} };

    is (length $id_donation, 32, 'donation id has 32 chars');

    # Votando nos projetos.
    rest_post "/api/candidate/$id_candidate/projects/$id_projects[0]/votes",
        name    => 'voting with invalid donation_id',
        is_fail => 1,
        params  => {
            donation_id => "536facb9b05a48e2adb15866353b62ee",
        },
    ;

    # O array @id_projects possui o id dos quatro projetos adicionados. Posso votar em, no maximo, três deles.
    # Então percorrerei o array três vezes e votarei em três projetos.
    for (1 .. 3 ) {
        my $id_project = shift @id_projects;

        rest_post "/api/candidate/$id_candidate/projects/$id_project/votes",
            name   => "voting with valid donation_id",
            code   => 200,
            params => {
                donation_id => $id_donation,
            },
        ;
    }

    # No ultimo id que sobrou (o quarto projeto), eu não devo poder votar pois já estourei o limite.
    rest_post "/api/candidate/$id_candidate/projects/$id_projects[-1]/votes",
        name    => "voting with valid donation_id",
        is_fail => 1,
        params  => {
            donation_id => $id_donation,
        },
    ;
};

done_testing();

