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

    my $candidate      = $schema->resultset("Candidate")->find($candidate_id);
    my $candidate_user = $candidate->user;

    is( $candidate_user->has_signed_contract, 0, "candidate didn't sign contract yet" );

    rest_get "/api/candidate/$candidate_id",
        name  => 'GET candidate data',
        list  => 1,
        stash => 'get_candidate_data'
    ;

    stash_test "get_candidate_data" => sub {
        my $res = shift;

        is ($res->{candidate}->{signed_contract}, 0, 'candidate has not signed contract yet');
    };

    rest_post "/api/candidate/$candidate_id/contract_signature",
        name                => 'signing contract',
        automatic_load_item => 0,
        stash               => 'c1'
    ;

    is( $candidate_user->has_signed_contract, 1, "candidate signed contract" );

    rest_post "/api/candidate/$candidate_id/contract_signature",
        name    => 'signing contract once again',
        is_fail => 1,
        code    => 400,
    ;

    rest_reload_list "get_candidate_data";

    stash_test "get_candidate_data.list" => sub {
        my $res = shift;

        is ($res->{candidate}->{signed_contract}, 1, 'candidate has signed contract');
    };
};

done_testing();

