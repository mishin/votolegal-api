use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    rest_post '/api/contact',
        name   => "contact",
        stash  => 'email',
        code   => 200,
        params => {
            name    => 'Junior Moraes',
            phone   => '11982012016',
            email   => 'fvox@cpan.org',
            message => "Morbi fringilla tellus eu maximus hendrerit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ex libero, scelerisque sed sem vel, aliquet interdum lacus."
        },
    ;

    my $email = stash 'email';
    ok ($schema->resultset('EmailQueue')->find($email->{id}), 'email queued');
};

done_testing();

