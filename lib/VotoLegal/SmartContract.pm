package VotoLegal::SmartContract;
use common::sense;
use Moose;
use namespace::autoclean;

use Proc::ProcessTable;
use JSON -support_by_pp;

use VotoLegal::Geth;

has account => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has password => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has address => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has abi => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has geth => (
    is      => "rw",
    isa     => "VotoLegal::Geth",
    default => sub { VotoLegal::Geth->new() },
);

has _json => (
    is      => "rw",
    default => sub { JSON->new->utf8(1)->allow_barekey(1) },
);

sub addDonation {
    my ( $self, $candidate, $donation, $gas ) = @_;

    defined $candidate or die "missing 'candidate'";
    defined $donation  or die "missing 'donation'";

    my $account  = $self->account;
    my $password = $self->password;
    my $address  = $self->address;
    my $abi      = $self->abi;
    $gas = $gas || 65000;

    my $gethCommand = <<"GETH_COMMAND";
var votoLegal = eth.contract($abi).at("$address");
personal.unlockAccount("$account", "$password");
votoLegal.addDonation("$candidate", "$donation", { from: "$account", gas: $gas });
exit;
GETH_COMMAND

    my $res = $self->geth->execute($gethCommand);

    return $res;
}

sub getAllDonationsFromCandidate {
    my ( $self, $candidate ) = @_;

    defined $candidate or die "missing 'candidate'";

    my $address = $self->address;
    my $abi     = $self->abi;

    my $gethCommand = <<"GETH_COMMAND";
var votoLegal = eth.contract($abi).at("$address");
votoLegal.getAllDonationsFromCandidate("$candidate");
exit;
GETH_COMMAND

    my $res  = $self->geth->execute($gethCommand);
    my $json = $self->_json->decode( $res->data->[-1] );

    if ( ref $json ) {
        return map {
            my @split = unpack "(A2)*", $_;
            shift @split;    # Removendo o 0x do inicio.

            # Quando a string gravada não possui 32 bytes, ela é completada com 0x00.
            @split = grep { $_ ne "00" } @split;
            @split = map  { chr( hex($_) ) } @split;
            join( "", @split );
        } @$json;
    }

    return;
}

sub getTransactionStatus {
    my ( $self, $txHash ) = @_;

    defined $txHash or die "missing 'txHash'.";

    my $res = $self->geth->execute("eth.getTransaction(\"$txHash\")");
    my $json = $self->_json->decode( join( "\n", @{ $res->data } ) );

    return $json;
}

sub getDonation {
    my ( $self, $donation ) = @_;

    defined $donation or die "missing 'donation'.";

    my $address = $self->address;
    my $abi     = $self->abi;

    my $gethCommand = <<"GETH_COMMAND";
var votoLegal = eth.contract($abi).at("$address");
votoLegal.getDonation("$donation");
exit;
GETH_COMMAND

    my $res = $self->geth->execute($gethCommand);

    if ( @{ $res->data } ) {
        return $res->data->[-1];
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;
