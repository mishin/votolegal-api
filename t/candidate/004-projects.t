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
};

done_testing();

