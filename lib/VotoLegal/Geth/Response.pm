package VotoLegal::Geth::Response;
use common::sense;
use Moose;
use namespace::autoclean;

has data => (
    is       => "ro",
    isa      => "ArrayRef[Str]",
    required => 1,
);

has _transactionHash => (
    is  => "rw",
    isa =>  "Str",
);

sub getTransactionHash {
    my ($self) = @_;

    if (!defined($self->_transactionHash)) {
        my $txid ;
        for my $line (@{ $self->data }) {
            if ($line =~ m{^"(0x[a-z0-9]{64})}) {
                $txid = $1;
            }
        }

        $self->_transactionHash($txid);
    }

    return $self->_transactionHash;
}

__PACKAGE__->meta->make_immutable;

1;
