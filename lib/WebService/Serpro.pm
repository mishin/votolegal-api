package WebService::Serpro;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Carp;

BEGIN {
    use VotoLegal::Utils qw/is_test/;

    if ( $ENV{SERPRO_ENABLED} && ( !is_test() || $ENV{TEST_SERPRO} ) ) {
        die "Missing SERPRO_AUTH"    unless $ENV{SERPRO_AUTH};
        die "Missing SERPRO_API_URL" unless $ENV{SERPRO_API_URL};

        $ENV{SERPRO_TEST} = 0;
    }
    else {
        $ENV{SERPRO_TEST} = 1;

    }
}

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

has 'session_token' => ( is => 'rw', );

sub _build_furl { Furl->new( timeout => 15 ) }

sub examine_cpf {
    my ($self, $cpf) = @_;

    my $result;

    if ( $ENV{SERPRO_TEST} ) {
        $result = $VotoLegal::Test::Further::serpro_response;
    }
    else {
        my $res = $self->furl->post(
            $ENV{SERPRO_API_URL} . '/consulta-cpf/v1/cpf/' . $cpf,
            [ 'Authorization', "Bearer $ENV{SERPRO_AUTH}" ],
        );

        die "Erro ao consultar cpf no Serpro: " . $res->decoded_content if $res->code != 200;

        $result = $res->decoded_content;
    }

    return $result;
}

1;