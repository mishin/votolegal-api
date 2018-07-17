package WebService::Dcrtime;
use common::sense;
use Moose;

use JSON::MaybeXS;
use Furl;
use Try::Tiny::Retry;
use URI::Escape;
use MIME::Base64;

has 'ua' => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_ua',
);

BEGIN { defined( $ENV{VOTOLEGAL_DCRTIME_API} ) or die "Missing env 'VOTOLEGAL_DCRTIME_API'"; }

sub timestamp {
    my ( $self, %opts ) = @_;

    my $headers = [];
    if ($ENV{VOTOLEGAL_DCRTIME_USERNAME} && $ENV{VOTOLEGAL_DCRTIME_PASSWD}) {
        my $username = uri_unescape($ENV{VOTOLEGAL_DCRTIME_USERNAME});
        my $passwd   = uri_unescape($ENV{VOTOLEGAL_DCRTIME_PASSWD});

        push @{ $headers }, ( 'Authorization' => 'Basic ' . encode_base64("$username:$passwd") );
    }

    my $res;
    eval {
        retry {
            $res = $self->ua->post( $ENV{VOTOLEGAL_DCRTIME_API} . '/v1/timestamp/', $headers, encode_json( \%opts ) );
            use DDP; p $res;
            die $res->decoded_content unless $res->is_success;
        }
        retry_if { shift() < 3 } catch { die $_; };
    };

    die "Error: $@" if $@;
    die "Cannot call Dcrtime" unless ref $res;
    die "Request failed: " . $res->as_string unless $res->is_success;

    return decode_json( $res->decoded_content );
}

sub verify {
    my ( $self, %opts ) = @_;

    my $res;
    eval {
        retry {
            $res = $self->ua->post( $ENV{VOTOLEGAL_DCRTIME_API} . '/v1/verify/', [], encode_json( \%opts ) );
            die $res->decoded_content unless $res->is_success;
        }
        retry_if { shift() < 3 } catch { die $_; };
    };

    die "Error: $@" if $@;
    die "Cannot call Dcrtime" unless ref $res;
    die "Request failed: " . $res->as_string unless $res->is_success;

    return decode_json( $res->decoded_content );
}

sub _build_ua { Furl->new( timeout => 30 ) }

__PACKAGE__->meta->make_immutable;

1;

