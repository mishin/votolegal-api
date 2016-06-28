package VotoLegal::Uploader;
use common::sense;
use MooseX::Singleton;

use URI;
use URI::Escape;
use Net::Amazon::S3;
use Digest::HMAC_SHA1;
use MIME::Base64 qw(encode_base64);

BEGIN {
    $ENV{VOTOLEGAL_AWS_ACCESS_KEY} || die 'missing VOTOLEGAL_AWS_ACCESS_KEY';
    $ENV{VOTOLEGAL_AWS_SECRET_KEY} || die 'missing VOTOLEGAL_AWS_SECRET_KEY';
}

has s3 => (
    is      => "ro",
    isa     => "Net::Amazon::S3",
    default => sub {
        my $s3 = Net::Amazon::S3->new({
            aws_access_key_id     => $ENV{VOTOLEGAL_AWS_ACCESS_KEY},
            aws_secret_access_key => $ENV{VOTOLEGAL_AWS_SECRET_KEY},
            retry                 => 1,
            timeout               => 3,
            secure                => 0,
        });

        return $s3;
    },
    handles => [qw(aws_access_key_id aws_secret_access_key err errstr)],
);

has bucket => (
    is      => "rw",
    isa     => "Str",
    default => $ENV{VOTOLEGAL_AWS_MEDIA_BUCKET},
);

sub upload {
    my ($self, $args) = @_;

    # Required args.
    defined $args->{$_}   or die "missing '$_'" for qw(file path type);
    defined $self->bucket or die "missing 'bucket'";

    my $bucket = $self->s3->bucket($self->bucket);

    $bucket->add_key_filename($args->{path}, $args->{file}, { content_type => $args->{type} });

    if ($self->err) {
        die "$self->err: '$self->errstr'";
    }

    my $sign_url = $self->_generate_auth_uri($args->{path}, 2056022152);

    return URI->new($sign_url);
}

sub _generate_auth_uri {
    my ($self, $path, $expires) = @_;

    my $bucket = $self->bucket;
    $expires ||= 2056022152;

    my $str = "GET\n\n\n$expires\n/$bucket/$path";

    my $access = uri_escape($self->aws_access_key_id);
    my $sig    = uri_escape($self->_encode($str));

    return "https://$bucket.s3.amazonaws.com/$path?AWSAccessKeyId=$access&Expires=$expires&Signature=$sig";
}

sub _encode {
    my ($self, $str) = @_;

    my $hmac = Digest::HMAC_SHA1->new($self->aws_secret_access_key);
    $hmac->add($str);

    return encode_base64($hmac->digest, '');
}

__PACKAGE__->meta->make_immutable;

1;
