use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

db_transaction {
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    # List.
    rest_get '/api/admin/candidate/list',
      name    => "pending candidates -- candidate is not allowed",
      is_fail => 1,
      code    => 403,
      params  => { status => "pending", },
      ;

    api_auth_as user_id => 1;
    rest_get '/api/admin/candidate/list',
      name   => "pending candidates",
      stash  => "pending",
      params => { status => "pending", },
      ;

    stash_test 'pending', sub {
        my $res = shift;

        is( ref $res, 'ARRAY' );

        # Todos os candidatos retornados estão realmente pendentes?
        for ( @{$res} ) {
            is( $_->{status}, "pending", "candidate id $_->{id} is pending" );
        }
    };

    # Count.
    rest_get '/api/admin/candidate/count',
      name   => "count pendings",
      stash  => "count",
      params => { status => "pending", },
      ;

    stash_test 'count' => sub {
        my $res = shift;

        ok( $res->{count} > 0, 'count pending candidates' );
    };
};

done_testing();

