use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    setup_time_for_contract_test_pre_campaign;

    my $email_queue_rs = $schema->resultset("EmailQueue");

    create_candidate;
    my $candidate_id = stash 'candidate.id';

    is( $email_queue_rs->count, 1, 'Registration email' );

    api_auth_as candidate_id => $candidate_id;

    my $candidate      = $schema->resultset("Candidate")->find($candidate_id);
    my $candidate_user = $candidate->user;

    is( $candidate_user->has_signed_contract_pre_campaign, 0, "candidate didn't sign contract yet" );

    rest_get "/api/candidate/$candidate_id",
      name  => 'GET candidate data',
      list  => 1,
      stash => 'get_candidate_data';

    stash_test "get_candidate_data" => sub {
        my $res = shift;

        is( $res->{candidate}->{signed_contract}, 0, 'candidate has not signed contract yet' );
    };

    rest_post "/api/candidate/$candidate_id/contract_signature",
      name                => 'signing contract',
      automatic_load_item => 0,
      stash               => 'c1';

    is( $email_queue_rs->count, 2, 'Registration and contract signature email' );

    is( $candidate_user->has_signed_contract_pre_campaign, 1, "candidate signed contract" );

    rest_post "/api/candidate/$candidate_id/contract_signature",
      name    => 'signing contract once again',
      is_fail => 1,
      code    => 400,
      ;

    rest_reload_list "get_candidate_data";

    stash_test "get_candidate_data.list" => sub {
        my $res = shift;

        is( $res->{candidate}->{signed_contract}, 1, 'candidate has signed contract' );
    };

    ok ( my $contract_signature_pc = $schema->resultset('ContractSignature')->find(stash 'c1.id'), 'contract signature' );
    is ( $contract_signature_pc->is_pre_campaign, 1, 'is pre-campaign' );

    setup_time_for_contract_test_campaign;

    rest_post "/api/candidate/$candidate_id/contract_signature",
	  name                => 'signing contract for campaign',
	  automatic_load_item => 0,
	  stash               => 'c2';
	  ;

    ok ( my $contract_signature_c = $schema->resultset('ContractSignature')->find(stash 'c2.id'), 'contract signature' );
    is ( $contract_signature_c->is_pre_campaign, 0, 'is normal campaign' );

	rest_post "/api/candidate/$candidate_id/contract_signature",
	  name    => 'signing contract for nomal campaign once again',
	  is_fail => 1,
	  code    => 400,
	  ;
};

done_testing();

