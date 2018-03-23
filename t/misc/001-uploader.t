use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use DateTime;
use Test::More;
use Crypt::PRNG qw(random_string);
use VotoLegal::Test::Further;

use_ok 'VotoLegal::Uploader';

my $uploader = new_ok('VotoLegal::Uploader');

my $path = join "/", "votolegal_dev", random_string(2), random_string(3), DateTime->now->datetime, "upload.txt";

ok(
    my $uri = $uploader->upload({
        path => $path,
        file => "$Bin/upload.txt",
        type => "text/plain",
    }),
    'upload file',
);

isa_ok( $uri, 'URI' );

done_testing();

