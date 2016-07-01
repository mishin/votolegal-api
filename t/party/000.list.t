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

    is (ref $res->{party}, 'ARRAY');
    ok (scalar @{ $res->{party} } > 0, 'has parties');

    my $all_parties_has_name_and_acronym = 1;
    for (@{ $res->{party} }) {
        $all_parties_has_name_and_acronym &= defined($_->{name}) && defined($_->{acronym});
    }

    ok ($all_parties_has_name_and_acronym, 'all parties has name and acronym');
};

done_testing();

