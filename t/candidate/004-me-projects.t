use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    rest_post '/api/me/projects',
        name   => "can't add project logged out",
        is_fail => 1,
        params => {
            title => "Projeto 1",
            scope => lorem_words(20),
        },
    ;

    api_auth_as candidate_id => stash 'candidate.id';
    rest_post '/api/me/projects',
        name   => "can't add project logged out",
        is_fail => 1,
        params => {
            title => "Projeto 1",
            scope => lorem_words(20),
        },
    ;
};

done_testing();

