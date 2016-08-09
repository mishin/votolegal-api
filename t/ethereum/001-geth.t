use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal;
use VotoLegal::Test::Further;

use VotoLegal::Geth;

my $geth = VotoLegal::Geth->new();

if (!$geth->isTestnet()) {
    plan skip_all => "geth isn't running on testnet.";
}

isa_ok $geth, 'VotoLegal::Geth';
ok (-x $geth->binary, 'binary is executable');

ok (my $account = VotoLegal->config->{ethereum}->{testnet}->{account}, 'get account from config');

my $res = $geth->execute("web3.fromWei(eth.getBalance(\"$account\"), \"ether\")");
isa_ok $res, 'VotoLegal::Geth::Response';

ok ($res->data->[0] > 0, 'account has ethers');

done_testing();

