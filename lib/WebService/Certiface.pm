package WebService::Certiface;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Try::Tiny::Retry;
use VotoLegal::Utils;

BEGIN {
    for (qw/ CERTIFACE_LOGIN CERTIFACE_PASSWORD /) {
        defined($ENV{$_}) or die "missing env '$_'\n";
    }
}

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new }

sub login {
    my ( $self ) = @_;

    if (is_test()) {
        return 1;
    }
    else {
        my $res;
        eval {
            retry {
                $res = $self->furl->post(
                    get_mandatoaberto_httpcb_url_for('/schedule'),
                    [],
                    {}
                );

                die $res->decoded_content unless $res->is_success;
            }
            retry_if { shift() < 3 } catch { die $_; };
        };
        die $@ if $@;

        return decode_json( $res->decoded_content );
    }
}

1;