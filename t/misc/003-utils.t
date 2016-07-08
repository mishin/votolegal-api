use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::More;

use_ok 'VotoLegal::Utils';

ok (is_test(), 'is_test');

done_testing();

