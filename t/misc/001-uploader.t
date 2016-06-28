use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use DateTime;
use Test::More;
use LWP::Simple;
use Crypt::PRNG qw(random_string);

use_ok 'VotoLegal::Uploader';

my $uploader = new_ok('VotoLegal::Uploader');
can_ok $uploader, 'bucket';

my $path = join "/", "votolegal_dev", random_string(2), random_string(3), DateTime->now->datetime, "upload.txt";

my $uri = $uploader->upload({
    path => $path,
    file => "$Bin/upload.txt",
    type => "text/plain",
});

isa_ok ($uri, 'URI');
is (get($uri), "fvox\n", 'file ok');

done_testing();

