use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    my $candidate = $schema->resultset('Candidate')->find(stash 'candidate.id');
    $candidate->update({ status => "activated" });

    # Search by name.
    rest_post "/api/search",
        name   => "search by name",
        stash  => 'name',
        code   => 200,
        params => {
            name => $candidate->popular_name,
            #issue_priorities => "1,2,3",
        },
    ;

    stash_test 'name' => sub {
        is (shift->[0]->{id}, $candidate->id, 'by name');
    };

    # Search by party_id.
    rest_post "/api/search",
        name   => "search by party_id",
        stash  => 'party',
        code   => 200,
        params => {
            name     => $candidate->popular_name,
            party_id => $candidate->party_id,
        },
    ;

    stash_test 'party' => sub {
        is (shift->[0]->{name}, $candidate->name, 'by party');
    };

    # Search by office_id.
    rest_post "/api/search",
        name   => "search by office_id",
        stash  => 'office',
        code   => 200,
        params => {
            name      => $candidate->popular_name,
            party_id  => $candidate->party_id,
            office_id => $candidate->office_id,
        },
    ;

    stash_test 'office' => sub {
        is (shift->[0]->{id}, $candidate->id, 'by office');
    };
};

done_testing();

