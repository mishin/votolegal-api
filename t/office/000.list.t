use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

rest_get '/api/office',
    name  => 'list offices',
    stash => 'office',
    code  => 200,
;

stash_test 'office', sub {
    my ($res) = @_;

    is (ref $res->{office}, 'ARRAY');

    ok (scalar @{ $res->{office} } > 0, 'has office');
};

done_testing();

