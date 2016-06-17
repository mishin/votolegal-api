use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    stash_test 'candidate.get', sub {
        my ($me) = @_;

        ok($me->{candidate}->{id} > 0, 'candidate id');
        is($me->{candidate}->{status}, "pending", 'candidate status pending');
    };

    my $candidate_id = stash 'candidate.id';
    my $candidate    = $schema->resultset('Candidate')->find($candidate_id);

    rest_post '/api/login',
        name    => 'candidate login --fail',
        is_fail => 1,
        [
            email => $candidate->user->email,
            password => 'wrongpassword',
        ],
    ;

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
        my ($me) = @_;

        is(length $me->{api_key}, 128, 'api key ok');
    };

};

done_testing();

