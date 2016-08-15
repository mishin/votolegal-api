use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

rest_get '/api/bank',
    name  => 'list banks',
    stash => 'bank',
;

done_testing();

