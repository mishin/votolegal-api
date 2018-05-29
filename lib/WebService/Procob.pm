package WebService::Procob;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Carp;

BEGIN {
    use VotoLegal::Utils qw/is_test/;

    if ( $ENV{PROCOB_ENABLED} && ( !is_test() || $ENV{TEST_PROCOB} ) ) {
        die "Missing PROCOB_AUTH"    unless $ENV{PROCOB_AUTH};
        die "Missing PROCOB_API_URL" unless $ENV{PROCOB_API_URL};

        $ENV{PROCOB_TEST} = 0;
    }
    else {
        $ENV{PROCOB_TEST} = 1;

    }
}

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

has 'session_token' => ( is => 'rw', );

sub _build_furl { Furl->new( timeout => 15 ) }

sub examine_cpf {
    my ($cpf) = @_;

    my $result;

    if ( $ENV{PROCOB_TEST} ) {

        $result = 'fake';
    }
    else {
        my $res = $self->furl->post(
            $ENV{PROCOB_API_URL} . '/consultas/v2/L0001/' . $cpf,
            [ 'Authorization', 'Basic' ],
        );

        die "Erro ao consultar cpf no Procob: " . $res->decoded_content if $res->code != 000;

        $result = $res->decoded_content;
    }

    return $result;
}
1;
