use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    my $candidate_id = stash 'candidate.id';
    my $candidate    = $schema->resultset('Candidate')->find($candidate_id);
    is ($candidate->status, "pending", 'candidate is pending');

    # Testando se realmente não posso ativar um candidato com permissão de usuário.
    api_auth_as candidate_id => stash 'candidate.id';
    rest_put "/api/admin/candidate/$candidate_id/activate",
        name    => 'activate candidate with user roles --fail',
        is_fail => 1,
        code    => 403,
    ;

    # As ações só podem ser executadas por admin.
    api_auth_as user_id => 1;

    # Ativando usuário.
    rest_put "/api/admin/candidate/$candidate_id/activate",
        name  => 'activate candidate',
        code  => 200,
    ;

    # Teste desativado temporariamente: o envio de email na troca de status está comentado enquanto não ajustamos o layout.
    #is(
    #    $schema->resultset('EmailQueue')->count,
    #    2,
    #    'two emails on queue',
    #);

    ok ($candidate->discard_changes, 'reload candidate');
    is ($candidate->status, "activated", 'candidate is activated');

    # Com permissão de usuário, não pode desativar.
    api_auth_as candidate_id => stash 'candidate.id';
    rest_put "/api/admin/candidate/$candidate_id/deactivate",
        name    => 'deactivate candidate with user roles --fail',
        is_fail => 1,
        code    => 403,
    ;

    # Como admin, deve desativar.
    api_auth_as user_id => 1;
    rest_put "/api/admin/candidate/$candidate_id/deactivate",
        name => 'deactivate candidate with admin role',
        code => 200,
    ;

    ok ($candidate->discard_changes, 'reload candidate');
    is ($candidate->status, "deactivated", 'candidate is activated');
};

done_testing();

