use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    stash_test 'candidate.get', sub {
        my ($res) = @_;

        ok( $res->{candidate}->{id} > 0, 'candidate id' );
        is( $res->{candidate}->{status}, "pending", 'candidate status pending' );
    };

    my $candidate_id = stash 'candidate.id';
    my $candidate    = $schema->resultset('Candidate')->find($candidate_id);

    # Utilizando uma senha incorreta.
    rest_post '/api/login',
      name    => 'candidate login --fail',
      is_fail => 1,
      [
        email    => $candidate->user->email,
        password => 'wrongpassword',
      ],
      ;

    # Senha correta.
    rest_post '/api/login',
      name  => 'candidate login',
      code  => 200,
      stash => 'login',
      [
        email    => $candidate->user->email,
        password => 'foobarquux1',
      ],
      ;

    stash_test 'login', sub {
        my ($res) = @_;

        is( $res->{candidate_id},   $candidate_id,    'candidate id' );
        is( $res->{candidate_name}, $candidate->name, 'candidate name' );
        is( $res->{campaign_donation_type}, 'pre-campaign', 'campaign_donation_type' );
		is( $res->{has_custom_site}, 0, 'candidate does not have custom site' );
        is( length $res->{api_key}, 14,               'api key' );
    };

    # Candidatos que não foram aprovados não podem logar na plataforma.
    api_auth_as user_id => 1;
    rest_put "/api/admin/candidate/$candidate_id/deactivate",
      name => 'deactivate candidate',
      code => 200,
      ;

    is( $candidate->discard_changes->status, 'deactivated', 'candidate is deactivated' );

    # Logando com a senha correta mas o candidato não foi aprovado.
    rest_post '/api/login',
      name    => 'candidate login when deactivated',
      is_fail => 1,
      [
        email    => $candidate->user->email,
        password => 'foobarquux1',
      ],
      ;
};

done_testing();

