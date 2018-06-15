use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    my $security_token = $ENV{MANDATOABERTO_SECURITY_TOKEN};

    my $email = fake_email()->();

    create_candidate( email => $email, );
    my $candidate_id = stash 'candidate.id';

    api_auth_as candidate_id => $candidate_id;

    rest_put "/api/candidate/$candidate_id",
        name    => 'fb_chat_plugin_code without integration',
        is_fail => 1,
        code    => 400,
        [
			fb_chat_plugin_code => '<!-- Load Facebook SDK for JavaScript -->
                <div id="fb-root"></div>
                <script>(function(d, s, id) {
                var js, fjs = d.getElementsByTagName(s)[0];
                if (d.getElementById(id)) return;
                js = d.createElement(s); js.id = id;
                js.src = "https://connect.facebook.net/en_US/sdk/xfbml.customerchat.js#xfbml=1&version=v2.12&autoLogAppEvents=1";
                fjs.parentNode.insertBefore(js, fjs);
                }(document, "script", "facebook-jssdk"));</script>

                <!-- Your customer chat code -->
                <div class="fb-customerchat"
                attribution="setup_tool"
                page_id="136021913750928">
                </div>'
        ]
    ;

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
        security_token   => $security_token
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'integration without mandatoaberto_id',
      is_fail => 1,
      code    => 400,
      [
        email          => $email,
        security_token => $security_token

      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'integration with invalid email (no user)',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => 'foobar@email.com',
        security_token   => $security_token
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'integration with invalid email (not a candidate)',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => 'juniorfvox@gmail.com',
        security_token   => $security_token
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'Integration without security token',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => $email,
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name    => 'Integration with invalid security token',
      is_fail => 1,
      code    => 400,
      [
        mandatoaberto_id => 42,
        email            => $email,
        security_token   => 'foobar'
      ];

    rest_post "/api/candidate/mandatoaberto_integration",
      name  => 'successful integration',
      code  => 200,
      stash => 'i1',
      [
        mandatoaberto_id => 42,
        email            => $email,
        security_token   => $security_token
      ];

    stash_test "i1" => sub {
        my $res = shift;

        is( $res->{username}, 'teste.votolegal', 'username' );
    };

    rest_get "/api/candidate/$candidate_id",
      name  => 'get candidate',
      list  => 1,
      stash => "get_candidate";

    stash_test "get_candidate" => sub {
        my $res = shift;

        is( $res->{candidate}->{has_mandatoaberto_integration}, 1, 'candidate has mandato aberto integration' );
        is( $res->{candidate}->{fb_chat_plugin_code}, undef, 'no code block yet' );
    };

	api_auth_as candidate_id => $candidate_id;

    rest_put "/api/candidate/$candidate_id",
        name    => 'fb_chat_plugin_code',
        [
			fb_chat_plugin_code => '<!-- Load Facebook SDK for JavaScript -->
                <div id="fb-root"></div>
                <script>(function(d, s, id) {
                var js, fjs = d.getElementsByTagName(s)[0];
                if (d.getElementById(id)) return;
                js = d.createElement(s); js.id = id;
                js.src = "https://connect.facebook.net/en_US/sdk/xfbml.customerchat.js#xfbml=1&version=v2.12&autoLogAppEvents=1";
                fjs.parentNode.insertBefore(js, fjs);
                }(document, "script", "facebook-jssdk"));</script>

                <!-- Your customer chat code -->
                <div class="fb-customerchat"
                attribution="setup_tool"
                page_id="136021913750928"
                theme_color="#fa3c4c"
				logged_in_greeting="Foo"
  				logged_out_greeting="Bar">
                </div>'
        ]
    ;

	rest_get "/api/candidate/$candidate_id",
	  name  => 'get candidate',
	  list  => 1,
	  stash => "get_candidate";

	stash_test "get_candidate" => sub {
		my $res = shift;

		is( $res->{candidate}->{has_mandatoaberto_integration}, 1, 'candidate has mandato aberto integration' );
        is( $res->{candidate}->{chat}->{page_id}, '136021913750928', 'page_id' );
		is( $res->{candidate}->{chat}->{theme_color}, '#fa3c4c', 'theme_color' );
		is( $res->{candidate}->{chat}->{logged_in_greeting}, 'Foo', 'logged_in_greeting' );
		is( $res->{candidate}->{chat}->{logged_out_greeting}, 'Bar', 'logged_out_greeting' );
		ok( defined( $res->{candidate}->{fb_chat_plugin_code} ), 'fb_chat_plugin_code is defined' );
	};
};

done_testing();