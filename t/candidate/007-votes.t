use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';
    my $candidate    = $schema->resultset('Candidate')->find($candidate_id);

    # Aprovando o candidato.
    ok(
        $candidate->update(
            {
                status         => "activated",
                payment_status => "paid",
            }
        ),
        'activate candidate',
    );

    # Preenchendo os campos de pagamento. Sem isso não acessamos nada referente a doações.
    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/$candidate_id",
      name   => 'edit candidate',
      params => {
        merchant_id        => fake_email->(),
        merchant_key       => random_string(32),
        payment_gateway_id => 2,
      },
      ;

    # Adicionando quatro projetos.
    my @id_projects = ();
    for ( 1 .. 4 ) {
        rest_post "/api/candidate/${candidate_id}/projects",
          name   => "adding project",
          stash  => "project",
          params => {
            title => "Project $_",
            scope => lorem_paragraphs(),
          },
          ;

        stash_test 'project' => sub { push @id_projects, $_[0]->{id} };
    }

    # Não consigo testar o PagSeguro, então vou inserir a doação manualmente.
    ok(
        my $donation = $schema->resultset("Donation")->create(
            {
                id                           => md5_hex(time),
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
                captured_at                  => \"now()",
                payment_gateway_code         => fake_digits("########-####-####-####-############")->(),
                by_votolegal                 => "true",
                donation_type_id             => 1,
                payment_gateway_id           => 2,
            }
        ),
        'add donation',
    );

    # Votando com um id inválido. Por segurança, o endpoint deve retornar 'ok' independente da entrada
    # a fim de evitar ataques de brute force.
    rest_post "/api/candidate/$candidate_id/donate/536facb9b05a48e2adb15866353b62ee/vote",
      name   => "vote with invalid donation_id",
      code   => 200,
      params => { project_id => join( ",", @id_projects ), },
      ;

    # Agora sim votarei com o donation_id correto.
    my $donation_id = $donation->id;

    rest_post "/api/candidate/$candidate_id/donate/$donation_id/vote",
      name   => "voting on two projects",
      code   => 200,
      params => { project_id => join( ",", @id_projects[ 0 .. 1 ] ), },
      ;

    # Contabilizando os votos do projeto.
    for my $project_id ( @id_projects[ 0 .. 1 ] ) {
        is(
            $schema->resultset('ProjectVote')->search( { project_id => $project_id } )->count,
            1, "project id $project_id has one vote",
        );
    }

    # Nesse momento do teste eu já votei em dois projetos. Se eu votar no mesmo projeto duas
    # vezes, esses votos não devem ser computados.
    rest_post "/api/candidate/$candidate_id/donate/$donation_id/vote",
      name   => "vote in the same projects",
      code   => 200,
      params => { project_id => join( ",", @id_projects[ 0 .. 1 ] ), },
      ;

    for my $project_id ( @id_projects[ 0 .. 1 ] ) {
        is(
            $schema->resultset('ProjectVote')->search( { project_id => $project_id } )->count,
            1, "project id $project_id has one vote",
        );
    }

    # Ok, agora vou votar em mais um projeto. Contando com esse serão três, e eu atingirei o limite.
    rest_post "/api/candidate/$candidate_id/donate/$donation_id/vote",
      name   => "voting on the third project",
      code   => 200,
      params => { project_id => $id_projects[2], },
      ;

    # Agora eu não devo poder votar em mais nenhum.
    rest_post "/api/candidate/$candidate_id/donate/$donation_id/vote",
      name    => "voting on the fourth project",
      is_fail => 1,
      params  => { project_id => $id_projects[3], },
      ;
};

done_testing();

