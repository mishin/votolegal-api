use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::More;

use VotoLegal::Test::Further;
use Digest::MD5 qw(md5_hex);

use_ok 'VotoLegal::Payment::Cielo';

my $cielo = new_ok ('VotoLegal::Payment::Cielo', => [
    %{ VotoLegal->config->{cielo}->{sandbox} },
    sandbox => 1,
]);

ok ($cielo->does('VotoLegal::Payment'), 'does VotoLegal::Payment');

# Tokenizando.
my $card_token = $cielo->tokenize_credit_card(
    credit_card_data => {
        credit_card => {
            validity     => "201805",
            name_on_card => "JUNIOR M MORAES",
            brand        => "visa",
        },
        secret => {
            number => "0000000000000001",
            cvv    => "123",
        },
    },
    order_data => {
        id     => md5_hex(time),
        amount => "100",
        name   => fake_name()->(),
    }
);

ok ($card_token, 'card token');

# Authorize.
ok ($cielo->do_authorization(), 'authorized');

# Capture.
ok ($cielo->do_capture(), 'captured');

done_testing();

