package VotoLegal::Worker;
use Moose::Role;

requires 'exec_item';
requires 'listen_queue';
requires 'run_once';

has timer => (
    is       => "ro",
    isa      => "Int",
    required => 1,
);

has logger => (
    is       => "rw",
    isa      => "Log::Log4perl::Logger",
    required => 0,
);

has config => (
    is      => "rw",
    isa     => "HashRef",
    default => sub { {} },
);

around [ qw/ listen_queue run_once exec_item / ] => sub {
    my $orig = shift;
    my $self = shift;

    my $ret = eval { $self->$orig(@_) };
    if ($@) {
        $self->logger->logdie($@) if ref $self->logger;
        die $@;
    }

    return $ret;
};

1;