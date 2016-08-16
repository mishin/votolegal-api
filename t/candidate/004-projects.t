use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Time::HiRes;
use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $id_candidate = stash 'candidate.id';

    # Listando os projetos.
    rest_get "/api/candidate/${id_candidate}/projects",
        name  => "listing projects",
        stash => "list1",
    ;

    stash_test "list1" => sub {
        my ($res) = @_;

        ok (scalar @{$res->{projects}} == 0, 'has no projects');
    };

    # Adicionando projeto.
    rest_post "/api/candidate/${id_candidate}/projects",
        name    => "can't add project when not logged in",
        is_fail => 1,
        code    => 403,
        params  => {
            title => ucfirst lorem_words(3),
            scope => lorem_paragraphs(),
        },
    ;

    api_auth_as candidate_id => stash 'candidate.id';

    rest_post "/api/candidate/${id_candidate}/projects",
        name   => "adding project",
        stash  => "project",
        params => {
            title => ucfirst lorem_words(3),
            scope => lorem_paragraphs(),
        },
    ;

    is (
        $schema->resultset('Project')->search({ candidate_id => $id_candidate })->count,
        1,
        'project added'
    );

    # Editando o projeto.
    rest_put stash 'project.url',
        name   => "editing project",
        stash  => "e1",
        params => {
            title => "Project 01",
        },
    ;

    is (
        $schema->resultset('Project')->find(stash 'project.id')->title,
        'Project 01',
        'project edited',
    );

    # Deletando o projeto.
    rest_delete stash 'project.url',
        name => "delete project",
    ;

    is (
        $schema->resultset('Project')->search({ candidate_id => $id_candidate })->count,
        0,
        'project deleted'
    );

    # Não é possível adicionar mais de 20 projetos.
    for (1 .. 20) {
        rest_post "/api/candidate/${id_candidate}/projects",
            name    => "adding project $_",
            stash   => "p$_",
            params  => {
                title => "Project $_",
                scope => lorem_paragraphs(),
            },
        ;

        # Mockando uma donation.
        my $donation_id = md5_hex(Time::HiRes::time());
        $schema->resultset('Donation')->create({
            id                           => $donation_id,
            candidate_id                 => $id_candidate,
            name                         => fake_name()->(),
            email                        => fake_email()->(),
            cpf                          => random_cpf(),
            phone                        => fake_digits("##########")->(),
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
            amount                       => 100,
            birthdate                    => "1992-05-02",
            receipt_id                   => 1,
            ip_address                   => "127.0.0.1",
            status                       => "captured",
        });

        $schema->resultset('Project')->find(stash "p$_.id")->project_votes->create({ donation_id => $donation_id });
    }

    rest_post "/api/candidate/${id_candidate}/projects",
        name    => "adding project 21",
        is_fail => 1,
        params  => {
            title => "Project 21",
            scope => lorem_paragraphs(),
        },
    ;

    # Listando os projetos com paginacao.
    rest_get "/api/candidate/${id_candidate}/projects",
        name   => "listing projects",
        stash  => "list2",
        params => {
            page    => 2,
            results => 5,
        },
    ;

    stash_test 'list2' => sub {
        my ($res) = @_;

        # A listagem retornou 5 projetos.
        ok (scalar @{$res->{projects}} == 5, 'has 5 projects');
    };
};

done_testing();

