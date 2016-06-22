use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    rest_put '/api/me',
        name    => "more issues than i can have",
        is_fail => 1,
        params  => {
            issue_priorities => "1,2,3,4,5,6,7,8,9",
        },
    ;

    rest_put '/api/me',
        name    => "invalid issue id",
        is_fail => 1,
        params  => {
            issue_priorities => "1,2,3,666",
        },
    ;

    rest_put '/api/me',
        name    => "edit issue priority",
        params  => {
            issue_priorities => "5,2,3,1",
        },
    ;

    is_deeply(
        [ sort { $a <=> $b } map { $_->id } $schema->resultset('Candidate')->find(stash 'candidate.id')->issue_priorities->all ],
        [1, 2, 3, 5],
        'issue priority edited',
    );

    rest_get '/api/me',
        name  => "get myself",
        stash => "me",
        code  => 200,
    ;

    stash_test 'me', sub {
        my ($res) = @_;

        my $candidate_issue_priorities = $res->{me}->{candidate_issue_priorities};

        my @issue_priority_id = ();
        for (@{$candidate_issue_priorities}) {
            push @issue_priority_id, $_->{issue_priority_id};
        }

        is_deeply(
            [ sort { $a <=> $b } @issue_priority_id ],
            [1, 2, 3, 5],
            'get issue priority',
        );
    };
};

done_testing();

