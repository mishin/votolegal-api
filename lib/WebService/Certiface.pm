package WebService::Certiface;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Carp;

use VotoLegal::Utils;

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

has 'session_token' => ( is => 'rw', );

sub _build_furl { Furl->new( timeout => 15 ) }

sub new_session {
    my ($self) = @_;

    my $token;

    if ( $ENV{CERTIFACE_TEST} ) {

        $token = $VotoLegal::Test::Further::new_session;

    }
    else {
        my $res = $self->furl->post(
            $ENV{CERTIFACE_API_URL} . '/login',
            [ 'Content-Type', 'application/json' ],
            encode_json(
                {
                    login    => $ENV{CERTIFACE_LOGIN},
                    password => $ENV{CERTIFACE_PASSWORD}
                }
            )
        );

        die "Erro ao fazer login no certiface: " . $res->decoded_content if $res->code != 200;

        $token = $res->decoded_content;
    }

    $self->session_token($token);

    return 1;
}

sub generate_token {
    my ( $self, $opts ) = @_;


    $opts->{$_} or croak "missing $_" for qw/cpf nascimento nome telefone/;
    croak 'data invalida' unless $opts->{nascimento} =~ /^(\d{2})\/(\d{2})\/(\d{4})$/;

    # trim
    $opts->{nome} =~ s/^\s+//;
    $opts->{nome} =~ s/\s+$//;

    # precisa ter pelo menos um nome com duas palavras
    croak 'nome invalido' unless $opts->{nome} =~ /\w\s\w/;

    $self->new_session() unless $self->session_token();

    my $res;

    if ( $ENV{CERTIFACE_TEST} ) {

        $res = $VotoLegal::Test::Further::generate_token;

    }
    else {
        my $retry = 1;
      RETRY:
        $res = $self->furl->post(
            $ENV{CERTIFACE_API_URL} . '/api/v1/protected/genToken',
            [ 'Content-Type', 'application/json', 'Authorization', $self->session_token(), ],
            encode_json($opts)
        );

        # token expirou, faz login e tenta novamente
        if ( $res->code == 500 ) {

            $self->new_session();

            $retry++;
            goto RETRY if $retry;
        }
        elsif ( $res->code != 200 ) {

            die "Erro ao criar token certiface: " . $res->decoded_content;
        }

        $res = decode_json( $res->decoded_content );
    }

    return $res;
}

sub get_token_information {
    my ( $self, $token_uuid ) = @_;

    $self->new_session() unless $self->session_token();

    my $res;

    if ( $ENV{CERTIFACE_TEST} ) {
        $res = $VotoLegal::Test::Further::get_token_information;
    }
    else {

        my $retry = 1;
      RETRY:
        $res = $self->furl->get( $ENV{CERTIFACE_API_URL} . '/api/v1/protected/token' . "/$token_uuid",
            [ 'Authorization', $self->session_token() ] );

        # token expirou, faz login e tenta novamente
        if ( $res->code == 500 ) {

            $self->new_session();

            $retry++;
            goto RETRY if $retry;
        }
        elsif ( $res->code == 404 ) {

            $res = undef;

        }
        elsif ( $res->code != 200 ) {

            die "Erro ao consultar certiface token: " . $res->decoded_content;
        }

        $res = decode_json( $res->decoded_content )

    }

    return $res;
}

1;
