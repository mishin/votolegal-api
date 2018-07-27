package WebService::Julios;
use common::sense;
use MooseX::Singleton;

use JSON;
use Furl;
use Carp;

BEGIN {
    use VotoLegal::Utils qw/is_test/;

    if ( $ENV{JULIOS_URL} && ( !is_test() || $ENV{JULIOS_ENABLED} ) ) {
        die "Missing JULIOS_API_KEY" unless $ENV{JULIOS_API_KEY};
        die "Missing JULIOS_URL"     unless $ENV{JULIOS_URL};

        $ENV{JULIOS_TEST} = 0;
    }
    else {
        $ENV{JULIOS_TEST} = 1;

    }
}

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new( timeout => 60 ) }

sub put_charge {
    my ( $self, $data ) = @_;

    my $res;

    if ( $ENV{JULIOS_TEST} ) {
        $res = $VotoLegal::Test::Further::julios_information;
    }
    else {

        $res = $self->furl->post(
            $ENV{JULIOS_URL} . '/master/customers-charges',
            [ 'Content-type', 'application/json' ],
            to_json($data)
        );

        if ( $res->code != 202 ) {
            die "Erro ao cadastrar no julios: " . $res->decoded_content;
        }

        $res = decode_json( $res->decoded_content ) if $res;

    }

    return $res;
}

sub new_customer {
    my ( $self, $data ) = @_;

    my $res;

    if ( $ENV{JULIOS_TEST} ) {
        $res = $VotoLegal::Test::Further::julios_information;
    }
    else {

        $res = $self->furl->post(
            $ENV{JULIOS_URL} . '/master/customers',
            [ 'Content-type', 'application/json' ],
            to_json($data)
        );

        if ( $res->code != 200 ) {
            die "Erro ao cadastrar no julios: " . $res->decoded_content;

        }

        $res = decode_json( $res->decoded_content ) if $res;

    }

    die 'Error cannot create new_customer: ' . eval{to_json($res)} unless $res->{customer}{id};

    return $res;
}

1;
