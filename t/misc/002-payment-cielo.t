use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::More;

use_ok 'VotoLegal::Payment::Cielo';

my $cielo = new_ok ('VotoLegal::Payment::Cielo', => [
    affiliation     => "1006993069",
    key             => "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3",
    soft_descriptor => "VotoLegalTest",
    sandbox         => 1,
]);

ok ($cielo->does('VotoLegal::Payment'), 'does VotoLegal::Payment');

# Tokenizando.
my $card_token = $cielo->tokenize_credit_card(
    credit_card_data => {
        credit_card => {
            validity     => "201805",
            name_on_card => "JUNIOR M MORAES",
        },
        secret => {
            number => "6362970000457013",
        },
    },
);

is (length $card_token, 44, 'card_token');

# Authorization.
my $auth = $cielo->do_authorization(
    token     => $card_token,
    remote_id => int(rand(100000) + 1),
    brand     => "elo",
    amount    => 100,   # 1 real.
);

ok ($auth->{authorized}, 'authorized');

# Capture.
my $capture = $cielo->do_capture(
    transaction_id => $auth->{transaction_id},
);

ok ($capture->{captured}, 'captured');

done_testing();

