use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    rest_get '/api/me',
        name  => 'get myself',
        stash => 'me',
        code  => 200;

    stash_test 'me', sub {
        my ($me) = @_;

        is ($me->{candidate}->{id}, stash 'candidate.id');
    };

    rest_put '/api/me',
        name    => "edit myself -- can't change status",
        is_fail => 1,
        params  => {
            status => "activated",
        },
    ;

    rest_put '/api/me',
        name   => 'edit candidate',
        params => {
            name                 => "Junior Moraes",
            popular_name         => "Junior do VotoLegal",
            address_street       => "Rua Tiradentes",
            address_house_number => 666,
        },
    ;

    rest_get '/api/me',
        name  => 'get myself after edit',
        stash => 'me2',
        code  => 200
    ;

    stash_test 'me2', sub {
        my ($me) = @_;

        is ($me->{candidate}->{name}, "Junior Moraes", 'name');
        is ($me->{candidate}->{popular_name}, "Junior do VotoLegal", 'popular name');
        is ($me->{candidate}->{address_street}, "Rua Tiradentes", 'address street');
        is ($me->{candidate}->{address_house_number}, 666, 'address house number');
    };
};

done_testing();

