package VotoLegal::Test::Further;
use common::sense;
use FindBin qw($RealBin);
use Carp;

use Test::More;
use Catalyst::Test q(VotoLegal);
use CatalystX::Eta::Test::REST;

use Text::Lorem;
use Config::General;
use Data::Printer;
use JSON::MaybeXS;
use Crypt::PRNG qw(random_string);
use Business::BR::CPF qw(random_cpf);
use Business::BR::CNPJ qw(random_cnpj format_cnpj);
use Data::Fake qw(Core Company Dates Internet Names Text);

# ugly hack
sub import {
    strict->import;
    warnings->import;

    no strict 'refs';

    my $caller = caller;

    while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } ) {
        next if $name eq 'BEGIN';     # don't export BEGIN blocks
        next if $name eq 'import';    # don't export this sub
        next unless *{$symbol}{CODE}; # export subs only

        my $imported = $caller . '::' . $name;
        *{$imported} = \*{$symbol};
    }
}

my $obj = CatalystX::Eta::Test::REST->new(
    do_request => sub {
        my $req = shift;

        eval 'do{my $x = $req->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        my ( $res, $c ) = ctx_request($req);
        eval 'do{my $x = $res->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        return $res;
    },
    decode_response => sub {
        my $res = shift;
        return undef unless $res->content;
        return decode_json( $res->content );
    }
);

for (qw/rest_get rest_put rest_head rest_delete rest_post rest_reload rest_reload_list/) {
    eval( 'sub ' . $_ . ' { return $obj->' . $_ . '(@_) }' );
}

sub stash_test ($&) {
    $obj->stash_ctx(@_);
}

sub stash ($) {
    $obj->stash->{ $_[0] };
}

sub test_instance { $obj }

sub db_transaction (&) {
    my ( $subref, $modelname ) = @_;

    my $schema = VotoLegal->model( $modelname || 'DB' );

    eval {
        $schema->txn_do(
            sub {
                $subref->($schema);
                die 'rollback';
            }
        );
    };
    die $@ unless $@ =~ /rollback/;
}

my $auth_user = {};

sub api_auth_as {
    my (%conf) = @_;

    if ( !exists( $conf{user_id} ) && !exists( $conf{candidate_id} ) && !exists( $conf{nobody} ) ) {
        croak "api_auth_as: missing 'user_id', 'candidate_id' or 'nobody'.";
    }

    if ( exists( $conf{nobody} ) ) {
        $obj->fixed_headers( [] );
        return;
    }

    my $user_id      = $conf{user_id};
    my $candidate_id = $conf{candidate_id};

    my $schema = VotoLegal->model( defined( $conf{model} ) ? $conf{model} : 'DB' );

    if ( defined($candidate_id) ) {
        $user_id = $schema->resultset('Candidate')->find($candidate_id)->user_id;
    }

    if ( $auth_user->{id} != $user_id ) {
        my $user = $schema->resultset('User')->find($user_id);

        croak 'api_auth_as: user not found' unless $user;

        my $session = $user->new_session( ip => "127.0.0.1" );

        $auth_user = {
            id      => $user_id,
            api_key => $session->{api_key},
        };
    }

    $obj->fixed_headers( [ 'x-api-key' => $auth_user->{api_key} ] );
}

sub create_candidate {
    my (%opts) = @_;

    my $name     = fake_name()->();
    my $username = lc $name;
    $username =~ s/\s+/_/g;

    my %params = (
        username             => $username,
        password             => "foobarquux1",
        name                 => fake_name()->(),
        popular_name         => fake_surname()->(),
        email                => fake_email()->(),
        cpf                  => random_cpf(),
        address_state        => 'SP',
        address_city         => 'Iguape',
        address_zipcode      => '11920-000',
        address_street       => "Rua Tiradentes",
        address_house_number => 1 + int( rand(2000) ),
        office_id            => fake_int( 1, 3 )->(),
        party_id             => fake_int( 1, 35 )->(),
        reelection           => fake_int( 0, 1 )->(),
        %opts,
    );

    return $obj->rest_post(
        '/api/register',
        name  => 'add candidate',
        stash => 'candidate',
        [%params],
    );
}

sub lorem_words {
    my ($words) = @_;

    my $lorem = Text::Lorem->new();

    return $lorem->words( $words || 5 );
}

sub lorem_paragraphs {
    my ($n) = @_;

    my $lorem = Text::Lorem->new();

    return $lorem->paragraphs( $n || 3 );
}

sub get_config {
    my $conf   = new Config::General("$RealBin/../../votolegal.conf");
    my %config = $conf->getall;

    return \%config;
}

sub create_candidate_contract_signature {
    my ($candidate_id) = @_;

    return $obj->rest_post(
        "/api/candidate/$candidate_id/contract_signature",
        name                => 'add candidate contract signature',
        stash               => 'contract_signature',
        automatic_load_item => 0
    );
}

sub generate_device_token {
    my $res = $obj->rest_post(
        "/api2/device-authentication",
        name    => 'generate_device_token',
        code    => 200,
        headers => [
            'User-Agent' =>
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/'
              . rand,
        ],
    );

    $obj->{stash}{auth_token} = $res->{auth_token};

}
1;
