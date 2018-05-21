use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Testando o GET.
    rest_get "/api/candidate/${candidate_id}",
        name  => 'get candidate',
        stash => 'get_logged_out',
    ;

    stash_test 'get_logged_out' => sub {
        my ($res) = @_;

        ok (!defined($res->{candidate}->{cnpj}), 'no cnpj');
    };

    api_auth_as candidate_id => $candidate_id;

    rest_get "/api/candidate/${candidate_id}",
        name  => 'get candidate',
        stash => 'get_logged_in',
    ;

    my $username ;
    stash_test 'get_logged_in' => sub {
        my ($res) = @_;

        my $candidate = $res->{candidate};

        ok (defined($candidate->{cpf}),  'cpf');
        is ($candidate->{signed_contract}, 0, 'user did not sign contract');
        is ($candidate->{paid},            0, 'user did not pay');
        is ($candidate->{color},           'default', 'default candidate color');

        $username = $res->{candidate}->{username};
    };

    # GET por username.
    rest_get "/api/candidate/$username",
        name  => 'get candidate by username',
    ;

    # Testando o PUT.
    rest_put "/api/candidate/${candidate_id}",
        name    => "edit myself -- can't change status",
        is_fail => 1,
        params  => {
            status => "activated",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            name                 => "Junior Moraes",
            popular_name         => "Junior do VotoLegal",
            address_street       => "Rua Tiradentes",
            address_house_number => 666,
        },
    ;

    # Cadastro completo.
    my $video_url          = "https://www.youtube.com/watch?v=Pff7fkgBzfQ";
    my $facebook_url       = "https://www.facebook.com/HumorIguapense/";
    my $twitter_url        = "https://twitter.com/fvox";
    my $instagram_url      = "https://www.instagram.com/fv0x/";
    my $website_url        = "http://eokoe.com/";
    my $summary            = "Meu nome é Junior, moro em Iguape e sou candidato a vereador.";
    my $biography          = "Duis enim nulla, elementum nec pellentesque et, auctor eget ligula. Etiam consequat est in mauris rutrum vulputate.";
    my $raising_goal       = 10560.80;
    my $public_email       = fake_email()->();
    my $responsible_name   = "Junior Moraes";
    my $responsible_email  = fake_email()->();
    my $merchant_id        = random_string(12);
    my $merchant_key       = random_string(20);

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid video url",
        is_fail => 1,
        params  => {
            video_url => "this_is_not_a_video_url",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid video url",
        is_fail => 1,
        params  => {
            video_url => "www.google.com",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "video url",
        params  => {
            video_url => "https://www.youtube.com/watch?v=49J9g5gCcWM",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid facebook url",
        is_fail => 1,
        params  => {
            facebook_url => "/juniorfvox",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid twitter url",
        is_fail => 1,
        params  => {
            twitter_url => '@fvox',
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid website url",
        is_fail => 1,
        params  => {
            website_url => "httttttttp://eokoe.com/",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't upload empty image",
        is_fail => 1,
        files   => {
            picture => "$Bin/empty.jpg",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't upload invalid spreadsheet",
        is_fail => 1,
        files   => {
            spending_spreadsheet => "$Bin/picture.jpg",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't set invalid political movement",
        is_fail => 1,
        [ political_movement_id => fake_int( 100, 200 )->() ],
    ;

    rest_put "/api/candidate/${candidate_id}",
        name  => 'edit myself',
        files => {
            picture              => "$Bin/picture.jpg",
            spending_spreadsheet => "$Bin/tse_spreadsheet.csv",
        },
        params => {
            video_url           => $video_url,
            facebook_url        => $facebook_url,
            twitter_url         => $twitter_url,
            instagram_url       => $instagram_url,
            website_url         => $website_url,
            summary             => $summary,
            biography           => $biography,
            raising_goal        => $raising_goal,
            public_email        => $public_email,
            responsible_name    => $responsible_name,
            responsible_email   => $responsible_email,
            merchant_id         => $merchant_id,
            merchant_key        => $merchant_key,
            phone               => fake_digits("###########")->(),
            address_district    => "Centro",
            bank_code           => "237",
            bank_agency         => "0120",
            bank_account_number => "1234",
            bank_account_dv     => "5",
            color               => 'yellow'
        },
    ;

    my $candidate = $schema->resultset('Candidate')->find($candidate_id);
    is ($candidate->video_url, $video_url, 'video_url');
    is ($candidate->facebook_url, $facebook_url, 'facebook_url');
    is ($candidate->instagram_url, $instagram_url, 'instagram_url');
    is ($candidate->website_url, $website_url, 'website_url');
    is ($candidate->summary, $summary, 'summary');
    is ($candidate->biography, $biography, 'biography');
    ok ($candidate->raising_goal == $raising_goal, 'raising goal');
    is ($candidate->public_email, $public_email, 'public email');
    ok ($candidate->spending_spreadsheet =~ m{^https?:\/\/}, 'spending spreadsheet');
    is ($candidate->responsible_name, $responsible_name, 'responsible name');
    is ($candidate->responsible_email, $responsible_email, 'responsible email');
    is ($candidate->merchant_id, $merchant_id, 'merchant_id');
    is ($candidate->merchant_key, $merchant_key, 'merchant_key');
    is ($candidate->address_district, "Centro", 'address district');
    ok ($candidate->phone =~ m{^\d+$}, 'phone');
    is ($candidate->bank_code->id, 237, 'bank code');
    is ($candidate->bank_agency, 120, 'bank agency');
    is ($candidate->bank_account_number, 1234, 'bank account number');
    is ($candidate->bank_account_dv, 5, 'bank account dv');
    is ($candidate->payment_gateway_id, 3, 'expected payment gateway id');
    ok ($candidate->color eq 'yellow', 'updated color');
    is ($candidate->publish, 0, 'not published');

    # Quando envio um campo em branco no PUT, deve setar NULL.
    rest_put "/api/candidate/${candidate_id}",
        name  => 'clear',
        params => {
            facebook_url        => "",
            responsible_email   => "",
            merchant_id         => "",
            merchant_key        => "",
            phone               => "",
            address_district    => "",
            bank_agency         => "",
        },
    ;

    ok ($candidate->discard_changes, 'discard changes');
    is ($candidate->facebook_url, undef, 'clear fb url');
    is ($candidate->responsible_email, undef, 'clear responsible email');
    is ($candidate->merchant_id, undef, 'clear merchant id');
    is ($candidate->merchant_key, undef, 'clear merchant key');
    is ($candidate->address_district, undef, 'clear address district');
    is ($candidate->phone, undef, 'clear phone');
    is ($candidate->bank_agency, undef, 'clear bank_agency');

    # Adicionando google analytics
    rest_put "/api/candidate/$candidate_id",
        name    => 'invalid google analytics id',
        is_fail => 1,
        [
            google_analytics => 'foobar'
        ]
    ;

    rest_put "/api/candidate/$candidate_id",
        name    => 'Google analytics id',
        [
            google_analytics => 'UA-11111-5'
        ]
    ;

    rest_put "/api/candidate/$candidate_id",
        name    => 'Google analytics id',
        [
            collect_donor_address => 1,
            collect_donor_phone   => 0
        ]
    ;

    ok ($candidate->discard_changes, 'discard changes');
    is ($candidate->google_analytics, 'UA-11111-5', 'google analytics');

    # Tentando editar outro candidato.
    create_candidate;
    rest_put "/api/candidate/" . stash 'candidate.id',
        name    => "can't edit other candidate",
        is_fail => 1,
        code    => 403,
        params  => {
            name => "Junior Moraes",
        },
    ;
};

done_testing();

