package VotoLegal::Worker::Blockchain;
use common::sense;
use Moose;

with 'VotoLegal::Worker';

has schema => (
    is       => "rw",
    required => 1,
);

sub listen_queue {}

sub run_once {}

sub exec_item {}

__PACKAGE__->meta->make_immutable;

1;

