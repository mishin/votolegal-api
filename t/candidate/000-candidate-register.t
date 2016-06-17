use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

db_transaction {
    create_candidate;

    stash_test 'candidate.get', sub {
        my ($me) = @_;

        ok($me->{candidate}->{id} > 0, 'candidate id');
        is($me->{candidate}->{status}, "pending", 'candidate status pending');
    };

};

done_testing();



