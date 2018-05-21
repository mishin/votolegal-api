package WebService::Dcrtime;
use common::sense;
use Moose;

use JSON::MaybeXS;
use Furl;
use Try::Tiny::Retry;

has 'ua' => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_ua',
);

BEGIN { defined($ENV{VOTOLEGAL_DCRTIME_API}) or die "Missing env 'VOTOLEGAL_DCRTIME_API'"; }

sub timestamp {
    my ($self, %opts) = @_;

    my $res;
    eval {
        retry {
            $res = $self->ua->post( $ENV{VOTOLEGAL_DCRTIME_API} . '/v1/timestamp/', [], encode_json(\%opts) );
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
    my ($self, %opts) = @_;

    my $res;
    eval {
        retry {
            $res = $self->ua->post( $ENV{VOTOLEGAL_DCRTIME_API} . '/v1/verify/', [], encode_json(\%opts) );
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

