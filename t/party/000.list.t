use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

rest_get '/api/party',
    name  => 'list political parties',
    stash => 'party',
    code  => 200,
;

stash_test 'party', sub {
    my ($res) = @_;

    is (ref $res->{parties}, 'ARRAY');
    ok (scalar @{ $res->{parties} } > 0, 'has parties');

    for (@{ $res->{parties} }) {
        ok (
            defined($_->{id}) && defined($_->{name}) && defined($_->{acronym}),
            'party has id, name and acronym',
        );
    }
};

done_testing();

