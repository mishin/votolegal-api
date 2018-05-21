use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';
    my $id_candidate = stash 'candidate.id';
    my $candidate    = $schema->resultset("Candidate")->find($id_candidate);

    # Não é possível publicar um candidato que ainda não foi aprovado.
    rest_post "/api/candidate/$id_candidate/publish",
      name    => "publish pending candidate",
      is_fail => 1,
      ;

    ok( $candidate->update( { status => "activated" } ), 'activate' );

    # Não é possível publicar um candidato que ainda não tenha pago o boleto.
    rest_post "/api/candidate/$id_candidate/publish",
      name    => "publish unpaid candidate",
      is_fail => 1,
      ;

    ok( $candidate->update( { payment_status => "paid" } ), 'do payment' );

    # Não é possível publicar um candidato que ainda não tenha preenchido os campos requeridos.
    rest_post "/api/candidate/$id_candidate/publish",
      name    => "not filled",
      is_fail => 1,
      ;

    # Preenchendo os campos.
    ok(
        $candidate->update(
            {
                cnpj                 => random_cnpj(),
                video_url            => "https://www.youtube.com/watch?v=smcY2SMU5Vc",
                summary              => lorem_paragraphs(),
                biography            => lorem_paragraphs(),
                public_email         => fake_email()->(),
                raising_goal         => fake_int( 1, 100_000 )->(),
                spending_spreadsheet => "http://mock.com/tse.csv",
                picture              => "http://mock.com/picture.jpg",
                merchant_id          => random_string(12),
                merchant_key         => random_string(20),
            }
        ),
        'full registration',
    );

    # Publicando.
    rest_post "/api/candidate/$id_candidate/publish",
      name => "publish pending candidate",
      code => 200,
      ;

    is( $candidate->discard_changes->publish, 1, 'published' );

    # Despublicando.
    rest_post "/api/candidate/$id_candidate/unpublish",
      name => "publish pending candidate",
      code => 200,
      ;

    is( $candidate->discard_changes->publish, 0, 'unpublished' );

    # Não posso publicar e nem despublicar se eu não for o proprio candidato.
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    rest_post "/api/candidate/$id_candidate/publish",
      name    => "trying to publish another candidate",
      is_fail => 1,
      code    => 403,
      ;

    rest_post "/api/candidate/$id_candidate/unpublish",
      name    => "trying to unpublish another candidate",
      is_fail => 1,
      code    => 403,
      ;
};

done_testing();

