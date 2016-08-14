use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate for 1 .. 5;
    $_->update({ status => "activated" }) for $schema->resultset('Candidate')->all;

    my $candidate = $schema->resultset('Candidate')->find(stash 'candidate.id');

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

    # Search by state.
    rest_post "/api/search",
        name   => "search by state",
        stash  => 'state',
        code   => 200,
        params => {
            address_state => "São Paulo",
        },
    ;

    stash_test 'state' => sub {
        my $res = shift;

        ok (grep($_->{id} == $candidate->id, @{$res}), 'by state');
    };

    # Search by city.
    rest_post "/api/search",
        name   => "search by city",
        stash  => 'city',
        code   => 200,
        params => {
            address_city => "Iguape",
        },
    ;

    stash_test 'city' => sub {
        my $res = shift;

        ok (grep($_->{id} == $candidate->id, @{$res}), 'by city');
    };

    # Paginação.
    rest_post "/api/search",
        name   => "pagination",
        stash  => "l1",
        code   => 200,
        params => {
            page    => 2,
            results => 1,
        },
    ;

    stash_test 'l1' => sub {
        my $res = shift;

        is (scalar @{$res}, 1, 'one result');
    };
};

done_testing();

