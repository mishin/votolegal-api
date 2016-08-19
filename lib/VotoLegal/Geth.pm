package VotoLegal::Geth;
use common::sense;
use Moose;
use namespace::autoclean;

use Unix::Whereis;
use VotoLegal::Geth::Response;

has binary => (
    is      => "rw",
    isa     => "Str",
    default => sub { whereis("geth") or die "'geth' not found." }
);

sub execute {
    my ($self, $command) = @_;

    defined $command or die "missing 'command'.";

    my $binary = $self->binary;

    my @data = map { chomp; $_ } `echo '$command' | $binary attach 2>&1`;

    return VotoLegal::Geth::Response->new(data => [ @data[9 .. $#data - 1] ]);
}

sub isRunning {
    my ($self) = @_;

    if (`ps -aef | grep geth | grep -v 'geth attach' | grep -v grep`) {
        return 1;
    }
    return 0;
}

sub isMainnet {
    my ($self) = @_;

    if (`ps -aef | grep geth | grep -v 'geth attach' | grep -v testnet | grep -v grep`) {
        return 1;
    }
    return 0;
}

sub isTestnet {
    my ($self) = @_;

    if (`ps -aef | grep geth | grep -v 'geth attach' | grep testnet | grep -v grep`) {
        return 1;
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;
