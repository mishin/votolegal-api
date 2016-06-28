use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $id_candidate = stash 'candidate.id';

    diag "Listing projects...";
    rest_get "/api/candidate/${id_candidate}/projects",
        name  => "listing projects",
        stash => "list1",
    ;

    stash_test "list1" => sub {
        my ($res) = @_;

        ok (scalar @{$res->{projects}} == 0, 'has no projects');
    };

    diag "Adding project...";

    rest_post "/api/candidate/${id_candidate}/projects",
        name    => "can't add project when not logged in",
        is_fail => 1,
        code    => 403,
        params  => {
            title => ucfirst lorem_words(3),
            scope => lorem_paragraphs(),
        },
    ;

    api_auth_as candidate_id => stash 'candidate.id';

    rest_post "/api/candidate/${id_candidate}/projects",
        name   => "adding project",
        stash  => "project",
        params => {
            title => ucfirst lorem_words(3),
            scope => lorem_paragraphs(),
        },
    ;

    is (
        $schema->resultset('Project')->search({ candidate_id => $id_candidate })->count,
        1,
        'project added'
    );

    diag "Edit project...";
    rest_put stash 'project.url',
        name   => "editing project",
        stash  => "e1",
        params => {
            title => "Project 01",
        },
    ;

    is (
        $schema->resultset('Project')->find(stash 'project.id')->title,
        'Project 01',
        'project edited',
    );

    diag "Delete project...";
    rest_delete stash 'project.url',
        name => "delete project",
    ;

    is (
        $schema->resultset('Project')->search({ candidate_id => $id_candidate })->count,
        0,
        'project deleted'
    );

    diag "Can't add more than 20 projects.";
    for (1 .. 20) {
        rest_post "/api/candidate/${id_candidate}/projects",
            name    => "adding project $_",
            params  => {
                title => "Project $_",
                scope => lorem_paragraphs(),
            },
        ;
    }

    rest_post "/api/candidate/${id_candidate}/projects",
        name    => "adding project 21",
        is_fail => 1,
        params  => {
            title => "Project 21",
            scope => lorem_paragraphs(),
        },
    ;
};

done_testing();

