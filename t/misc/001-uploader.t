use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Furl;
use DateTime;
use Test::More;
use Crypt::PRNG qw(random_string);
use VotoLegal::Test::Further;

use_ok 'VotoLegal::Uploader';

my $uploader = new_ok('VotoLegal::Uploader');

my $path = join "/", "votolegal_dev", random_string(2), random_string(3), DateTime->now->datetime, "upload.txt";

my $uri = $uploader->upload({
    path => $path,
    file => "$Bin/upload.txt",
    type => "text/plain",
});

isa_ok ($uri, 'URI');

my $furl = Furl->new(
    headers => ['Accept-Encoding' => 'gzip'],
);

my $req = $furl->get($uri->as_string);

is ($req->content, "fvox\n", 'file ok');

done_testing();

