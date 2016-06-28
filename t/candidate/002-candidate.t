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
    my $video_url     = "https://www.youtube.com/watch?v=Pff7fkgBzfQ";
    my $facebook_url  = "https://www.facebook.com/HumorIguapense/";
    my $twitter_url   = "https://twitter.com/fvox";
    my $instagram_url = "https://www.instagram.com/fv0x/";
    my $website_url   = "http://eokoe.com/";
    my $summary       = "Meu nome é Junior, moro em Iguape e sou candidato a vereador.";
    my $biography     = "Duis enim nulla, elementum nec pellentesque et, auctor eget ligula. Etiam consequat est in mauris rutrum vulputate.";
    my $cielo_token   = "6OwXjLLtn0YHXpK440fJBNPb49WR8jZK";

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
        name  => 'edit myself',
        files => {
            picture => "$Bin/picture.jpg",
        },
        params => {
            video_url     => $video_url,
            facebook_url  => $facebook_url,
            twitter_url   => $twitter_url,
            instagram_url => $instagram_url,
            website_url   => $website_url,
            summary       => $summary,
            biography     => $biography,
            cielo_token   => $cielo_token,
        },
    ;

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

