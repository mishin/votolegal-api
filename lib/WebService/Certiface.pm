package WebService::Certiface;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Try::Tiny::Retry;
use VotoLegal::Utils;

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new }

sub login {
    my ( $self ) = @_;

    my $res;
    eval {
        retry {
            $res = $self->furl->post(
                $ENV{CERTIFACE_API_URL} . '/login',
                [ 'Content-Type', 'application/json' ],
                encode_json(
                    {
                        login    => $ENV{CERTIFACE_LOGIN},
                        password => $ENV{CERTIFACE_PASSWORD}
                    }
                )
            );

            die $res->decoded_content unless $res->is_success;
        }
        retry_if { shift() < 3 } catch { die $_; };
    };
    die $@ if $@;

    return $res->decoded_content;
}

sub generate_token {
    my ( $self, $opts ) = @_;

    my $bearer_token = $self->login();

    my $res;
    eval {
        retry {
            $res = $self->furl->post(
                $ENV{CERTIFACE_API_URL} . '/api/v1/protected/genToken',
                [ 'Content-Type', 'application/json', 'Authorization', "$bearer_token" ],
                encode_json($opts)
            );

            die $res->decoded_content unless $res->is_success;
        }
        retry_if { shift() < 3 } catch { die $_; };
    };
    die $@ if $@;

    return decode_json( $res->decoded_content );

}

sub get_token_information {
    my ( $self, $token_uuid ) = @_;

    my $bearer_token = $self->login();

    my $res;
    eval {
        retry {
            $res = $self->furl->get(
                $ENV{CERTIFACE_API_URL} . '/api/v1/protected/token' . "/$token_uuid",
                [ 'Authorization', "$bearer_token" ]
            );

            die $res->decoded_content unless $res->is_success;
        }
        retry_if { shift() < 3 } catch { die $_; };
    };
    die $@ if $@;

    return decode_json( $res->decoded_content );
}

1;