use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal;
use VotoLegal::Test::Further;
use Digest::MD5 qw(md5_hex);

use VotoLegal::SmartContract;

my $smartContract = VotoLegal::SmartContract->new(%{ VotoLegal->config->{ethereum}->{testnet} });

if (!$smartContract->geth->isTestnet()) {
    plan skip_all => "geth isn't running on testnet.";
}

db_transaction {
    create_candidate;
    my $id_candidate = stash 'candidate.id';
    my $id_donation  = md5_hex(time());

    ok (my $res = $smartContract->addDonation($id_candidate, $id_donation), 'add donation');

    isa_ok $res, 'VotoLegal::Geth::Response';

    my $transactionHash = $res->getTransactionHash();

    is (length($transactionHash), 66, 'transaction hash has 66 chars');

    my $isTxConfirmed = 0;
    RETRY: for ( 1 .. 20 ) {
        my $txStatus    = $smartContract->getTransactionStatus($transactionHash);
        my $blockNumber = $txStatus->{blockNumber};

        if (defined($blockNumber)) {
            $isTxConfirmed = 1;
            last;
        }
        sleep 5;
    }

    ok ($isTxConfirmed, 'tx confirmed');

    is_deeply(
        [ $smartContract->getAllDonationsFromCandidate($id_candidate) ],
        [ $id_donation ],
        'getAllDonationsFromCandidate'
    );

    is ($smartContract->getDonation($id_donation), $id_candidate, 'getDonation');

};

done_testing();

