package VotoLegal::Worker::Blockchain;
use common::sense;
use Moose;

use VotoLegal::Utils;
use VotoLegal::SmartContract;

use Data::Printer;

with 'VotoLegal::Worker';

has schema => (
    is       => "rw",
    required => 1,
);

has timer => (
    is      => "rw",
    default => 5,
);

has smartContract => (
    is         => "rw",
    isa        => "VotoLegal::SmartContract",
    lazy_build => 1,
);

sub listen_queue {
    my ($self) = @_;

    $self->logger->debug("Buscando itens na fila...") if $self->logger;
}

sub run_once {
    my ($self, $item_id) = @_;

    my $item ;
    if (defined($item_id)) {
        $item = $self->schema->resultset("Donation")->search({
            id               => $item_id,
            transaction_hash => undef,
        });
    }
    else {
        $item = $self->schema->resultset("Donation")->search(
            { transaction_hash => undef },
            { rows             => 1 },
        )->next;
    }

    if (ref $item) {
        return $self->exec_item($item);
    }
    return 0;
}

sub exec_item {
    my ($self, $donation) = @_;

    my $donation_id = $donation->id;

    $self->logger->info("Processando a doação id '$donation_id'...") if $self->logger;

    my $cpf = $donation->candidate->cpf;
    my $res = $self->smartContract->addDonation($cpf, $donation->id);

    p $res;

    return 0;
}

sub _build_smartContract {
    my ($self) = @_;

    my $environment = is_test() ? "testnet" : "mainnet";

    my $smartContract = VotoLegal::SmartContract->new(
        %{ $self->config->{ethereum}->{$environment} }
    );

    die "geth isn't running." unless $smartContract->geth->isRunning();

    if (is_test()) {
        $smartContract->geth->isTestnet() or die "geth isn't running on testnet.";
    }
    else {
        $smartContract->geth->isMainnet() or die "geth isn't running on mainnet.";
    }


    return $smartContract;
}

__PACKAGE__->meta->make_immutable;

1;

