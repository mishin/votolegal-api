use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    # Testando os dados do pré cadastro.
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    rest_get '/api/me',
        name  => 'get myself',
        stash => 'me',
        code  => 200;

    stash_test 'me', sub {
        my ($res) = @_;

        is ($res->{me}->{id}, stash 'candidate.id');
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
        my ($res) = @_;

        is ($res->{me}->{name}, "Junior Moraes", 'name');
        is ($res->{me}->{popular_name}, "Junior do VotoLegal", 'popular name');
        is ($res->{me}->{address_street}, "Rua Tiradentes", 'address street');
        is ($res->{me}->{address_house_number}, 666, 'address house number');
    };

    # Cadastro completo.
    my $video_url    = "https://www.youtube.com/watch?v=Pff7fkgBzfQ";
    my $facebook_url = "https://www.facebook.com/HumorIguapense/";
    my $twitter_url  = "https://twitter.com/fvox";
    my $website_url  = "http://eokoe.com/";
    my $summary      = "Meu nome é Junior, moro em Iguape e sou candidato a vereador.";
    my $biography    = "Duis enim nulla, elementum nec pellentesque et, auctor eget ligula. Etiam consequat est in mauris rutrum vulputate.";
    my $cielo_token  = "6OwXjLLtn0YHXpK440fJBNPb49WR8jZK";

    rest_put '/api/me',
        name    => "can't add invalid video url",
        is_fail => 1,
        params  => {
            video_url => "this_is_not_a_video_url",
        },
    ;

    rest_put '/api/me',
        name    => "can't add invalid facebook url",
        is_fail => 1,
        params  => {
            facebook_url => $twitter_url,
        },
    ;

    rest_put '/api/me',
        name    => "can't add invalid twitter url",
        is_fail => 1,
        params  => {
            twitter_url => $website_url,
        },
    ;

    rest_put '/api/me',
        name    => "can't add invalid website url",
        is_fail => 1,
        params  => {
            website_url => "httttttttp://eokoe.com/",
        },
    ;

    rest_put '/api/me',
        name    => "can't upload empty image",
        is_fail => 1,
        files   => {
            file => "$Bin/empty.jpg",
        },
    ;

    rest_put '/api/me',
        name  => 'edit myself',
        files => {
            file => "$Bin/picture.jpg",
        },
        params => {
            video_url    => $video_url,
            facebook_url => $facebook_url,
            twitter_url  => $twitter_url,
            website_url  => $website_url,
            summary      => $summary,
            biography    => $biography,
            cielo_token  => $cielo_token,
        },
    ;

    my $candidate = $schema->resultset('Candidate')->find(stash 'candidate.id');

    ok ($candidate->picture =~ m{https?:\/\/}, 'picture url');
    is ($candidate->video_url, $video_url, 'video url');
    is ($candidate->facebook_url, $facebook_url, 'facebook url');
    is ($candidate->twitter_url, $twitter_url, 'twitter url');
    is ($candidate->website_url, $website_url, 'website url');
    is ($candidate->summary, $summary, 'summary');
    is ($candidate->biography, $biography, 'biography');
    is ($candidate->cielo_token, $cielo_token, 'cielo token');
};

done_testing();

