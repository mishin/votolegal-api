use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    my $security_token = $ENV{MANDATOABERTO_SECURITY_TOKEN};

    my $email   = fake_email()->();
    my $page_id = 'foobar';

    create_candidate( email => $email, );
    my $candidate_id = stash 'candidate.id';

    api_auth_as candidate_id => $candidate_id;

    my $candidate      = $schema->resultset("Candidate")->find($candidate_id);
    my $candidate_user = $candidate->user;

    $candidate->update( { username => 'teste.votolegal' } );

    api_auth_as 'nobody';

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'integration without email',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        security_token   => $security_token,
        page_id          => $page_id
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'integration without mandatoaberto_id',
      is_fail => 1,
      code    => 400,
      [
        email          => $email,
        page_id        => $page_id,
        security_token => $security_token,

      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'integration with invalid email (no user)',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => 'foobar@email.com',
        security_token   => $security_token,
        page_id          => $page_id
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'integration with invalid email (not a candidate)',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => 'juniorfvox@gmail.com',
        security_token   => $security_token,
        page_id          => $page_id
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'Integration without security token',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => $email,
        page_id          => $page_id
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'Integration with invalid security token',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => $email,
        security_token   => 'foobar',
        page_id          => $page_id
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'Integration without page_id',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => $email,
        security_token   => $security_token
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'Integration with greeting greater than 80 chars',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => $email,
        security_token   => $security_token,
        page_id          => $page_id,
        greeting         => 'This is just a large phrase repeated over and over. This is just a large phrase repeated over and over.'
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name  => 'successful integration',
      code  => 200,
      stash => 'i1',
      [
        mandatoaberto_id => 42,
        email            => $email,
        security_token   => $security_token,
        page_id          => $page_id,
        greeting         => 'fake greeting'
      ];

    stash_test "i1" => sub {
        my $res = shift;

        is( $res->{username}, 'teste.votolegal', 'username' );
    };

    rest_get "/api/candidate/$candidate_id",
        name  => 'get candidate data',
        list  => 1,
        stash => 'get_candidate_data'
    ;

    stash_test 'get_candidate_data' => sub {
        my $res = shift;

        is ( $res->{candidate}->{chat}->{page_id},            'foobar',        'page id' );
        is ( $res->{candidate}->{chat}->{logged_in_greeting}, 'fake greeting', 'greeting' );
    }

};

done_testing();