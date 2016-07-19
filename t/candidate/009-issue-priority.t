use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

rest_get '/api/issue_priority',
    name  => 'list issue priorities',
    stash => 'ip',
;

stash_test 'ip', sub {
    my $res = shift;

    is (ref $res->{issue_priority}, 'ARRAY');
    ok (@{ $res->{issue_priority} } > 0, 'has issue priority');
};

done_testing();

