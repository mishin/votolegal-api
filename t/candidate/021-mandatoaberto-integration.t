use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    my $security_token = $ENV{MANDATOABERTO_SECURITY_TOKEN};

    my $email = fake_email()->();

    create_candidate(
        email => $email,
    );
    my $candidate_id = stash 'candidate.id';

    api_auth_as candidate_id => $candidate_id;

    my $candidate      = $schema->resultset("Candidate")->find($candidate_id);
    my $candidate_user = $candidate->user;

    $candidate->update( { website_url => 'teste.votolegal.com.br' } );

    api_auth_as => 'nobody';

    rest_post "/api/candidate/mandatoaberto_integration",
        name    => 'integration without email',
        is_fail => 1,
        code    => 400,
        [
            mandatoaberto_id => 42,
            security_token   => $security_token
        ]
    ;

    rest_post "/api/candidate/mandatoaberto_integration",
        name    => 'integration without mandatoaberto_id',
        is_fail => 1,
        code    => 400,
        [
            email          => $email,
            security_token => $security_token

        ]
    ;

    rest_post "/api/candidate/mandatoaberto_integration",
        name    => 'integration with invalid email (no user)',
        is_fail => 1,
        code    => 400,
        [
            mandatoaberto_id => 42,
            email            => 'foobar@email.com',
            security_token   => $security_token
        ]
    ;

    rest_post "/api/candidate/mandatoaberto_integration",
        name    => 'integration with invalid email (not a candidate)',
        is_fail => 1,
        code    => 400,
        [
            mandatoaberto_id => 42,
            email            => 'juniorfvox@gmail.com',
            security_token   => $security_token
        ]
    ;

    rest_post "/api/candidate/mandatoaberto_integration",
        name    => 'Integration without security token',
        is_fail => 1,
        code    => 400,
        [
            mandatoaberto_id => 42,
            email            => $email,
        ]
    ;

    rest_post "/api/candidate/mandatoaberto_integration",
        name    => 'Integration with invalid security token',
        is_fail => 1,
        code    => 400,
        [
            mandatoaberto_id => 42,
            email            => $email,
            security_token   => 'foobar'
        ]
    ;

    rest_post "/api/candidate/mandatoaberto_integration",
        name  => 'successful integration',
        code  => 200,
        stash => 'i1',
        [
            mandatoaberto_id => 42,
            email            => $email,
            security_token   => $security_token
        ]
    ;

    stash_test "i1" => sub {
        my $res = shift;

        is ($res->{website_url}, 'teste.votolegal.com.br', 'url');
    };

    rest_get "/api/candidate/$candidate_id",
        name  => 'get candidate',
        list  => 1,
        stash => "get_candidate"
    ;

    stash_test "get_candidate" => sub {
        my $res = shift;

        is ($res->{candidate}->{has_mandatoaberto_integration}, 1, 'candidate has mandato aberto integration');
    }
};

done_testing();

