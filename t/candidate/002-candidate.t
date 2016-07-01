use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Testando o GET.
    diag "Testing GET...";
    rest_get "/api/candidate/${candidate_id}",
        name  => 'get candidate',
        stash => 'get_logged_out',
    ;

    stash_test 'get_logged_out' => sub {
        my ($res) = @_;

        ok (!defined($res->{candidate}->{cpf}),  'no cpf');
        ok (!defined($res->{candidate}->{cnpj}), 'no cnpj');
    };

    api_auth_as candidate_id => $candidate_id;

    rest_get "/api/candidate/${candidate_id}",
        name  => 'get candidate',
        stash => 'get_logged_in',
    ;

    stash_test 'get_logged_in' => sub {
        my ($res) = @_;

        ok (defined($res->{candidate}->{cpf}),  'cpf');
        ok (defined($res->{candidate}->{cnpj}), 'cnpj');
    };

    # Testando o PUT.
    diag "Testing PUT...";
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
    my $cielo_merchant_id  = random_string(12);
    my $cielo_merchant_key = random_string(20);

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid video url",
        is_fail => 1,
        params  => {
            video_url => "this_is_not_a_video_url",
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid facebook url",
        is_fail => 1,
        params  => {
            facebook_url => $twitter_url,
        },
    ;

    rest_put "/api/candidate/${candidate_id}",
        name    => "can't add invalid twitter url",
        is_fail => 1,
        params  => {
            twitter_url => $website_url,
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
        name  => 'edit myself',
        files => {
            picture              => "$Bin/picture.jpg",
            spending_spreadsheet => "$Bin/tse_spreadsheet.csv",
        },
        params => {
            video_url          => $video_url,
            facebook_url       => $facebook_url,
            twitter_url        => $twitter_url,
            instagram_url      => $instagram_url,
            website_url        => $website_url,
            summary            => $summary,
            biography          => $biography,
            raising_goal       => $raising_goal,
            public_email       => $public_email,
            responsible_name   => $responsible_name,
            responsible_email  => $responsible_email,
            cielo_merchant_id  => $cielo_merchant_id,
            cielo_merchant_key => $cielo_merchant_key,
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
    is ($candidate->cielo_merchant_id, $cielo_merchant_id, 'cielo_merchant_id');
    is ($candidate->cielo_merchant_key, $cielo_merchant_key, 'cielo_merchant_key');

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

