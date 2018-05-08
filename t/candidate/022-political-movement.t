use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

rest_get '/api/political_movement',
    name  => 'list political_movement',
    stash => 'political_movement',
    code  => 200,
;

stash_test 'political_movement', sub {
    my ($res) = @_;

    is (ref $res->{political_movement}, 'ARRAY');

    ok (scalar @{ $res->{political_movement} } > 0, 'has political_movement');
};

done_testing();

