use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

plan skip_all => "geth disabled." if exists $ENV{VOTOLEGAL_NO_GETH} && $ENV{VOTOLEGAL_NO_GETH};

use VotoLegal::Utils;
use VotoLegal::SmartContract;

my $smartContract = VotoLegal::SmartContract->new(%{ VotoLegal->config->{ethereum}->{testnet} });

if (!$smartContract->geth->isTestnet()) {
    plan skip_all => "geth isn't running on testnet.";
}

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    my $candidate = $schema->resultset("Candidate")->find(stash 'candidate.id');
    my $amount    = fake_int(1000, 50000)->();
    my $date      = DateTime->now(time_zone => "America/Sao_Paulo")->strftime('%Y%m%d');
    my $donation  = random_cpf() . "-" . $amount . "-" . $date;

    ok (my $res = $smartContract->addDonation($candidate->cpf, $donation), 'add donation');

    isa_ok $res, 'VotoLegal::Geth::Response';

    my $transactionHash = $res->getTransactionHash();

    is (length($transactionHash), 66, 'transaction hash has 66 chars');
    my $isTxConfirmed = 0;

    for ( 1 .. 25 ) {
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
        [ $smartContract->getAllDonationsFromCandidate($candidate->cpf) ],
        [ $donation ],
        'getAllDonationsFromCandidate'
    );
};

done_testing();

