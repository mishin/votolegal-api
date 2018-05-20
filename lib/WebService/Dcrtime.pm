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

    #if (is_test()) {
    if (0) {
        return {
            id      => "votolegal",
            results => [ 1 ],
            digests => [ "c6b52210addac4bde43c8ce66de95888f185925f3281af960c172c7c3c19b875" ],
            servertimestamp => 1526839200,
        };
    }
    else {
        my $res;
        eval {
            retry {
                $res = $self->furl->put( $ENV{VOTOLEGAL_DCRTIME_API} . '/v1/timestamp', [], [ encode_json(%opts) ] );
                die $res->decoded_content unless $res->is_success;
            }
            retry_if { shift() < 3 } catch { die $_; };
        };

        die "Error: $@" if $@;
        die "Cannot call Dcrtime" unless ref $res;
        die "Request failed: " . $res->as_string unless $res->is_success;

        return decode_json( $res->decoded_content );
    }
}

sub _build_furl { Furl->new( timeout => 30 ) }

1;

