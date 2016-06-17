use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {

    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    rest_get '/api/admin/candidate',
        name    => "pending candidates -- candidate is not allowed",
        is_fail => 1,
        code    => 403,
        params  => {
            status => "pending",
        },
    ;

    api_auth_as user_id => 1;

    rest_get '/api/admin/candidate',
        name   => "pending candidates",
        stash  => "pending",
        code   => 200,
        params => {
            status => "pending",
        },
    ;

    stash_test 'pending', sub {
        my ($res) = @_;

        is (ref $res, 'ARRAY');

        # Todos os candidatos retornados estão realmente pendentes?
        for (@{ $res }) {
            is ($_->{status}, "pending", "candidate id $_->{id} is pending");
        }
    };
};

done_testing();



