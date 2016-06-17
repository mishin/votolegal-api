use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

db_transaction {
    create_candidate;
};

done_testing();



