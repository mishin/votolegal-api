use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

plan skip_all => 'skip troubleshoot';

my $schema = VotoLegal->model('DB');

db_transaction {
    rest_post '/api/troubleshoot',
        name   => "contact",
        stash  => 't1',
        code   => 200,
        params => {
            route => "/api/troubleshoot",
            error => "TypeError: 'undefined' is not a function",
        },
    ;

    my $email = stash 't1';
    ok ($schema->resultset('EmailQueue')->find($email->{id}), 'email queued');
};

done_testing();

