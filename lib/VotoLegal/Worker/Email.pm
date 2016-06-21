package VotoLegal::Worker::Email;
use common::sense;
use Moose;

with 'VotoLegal::Worker';

use VotoLegal::Mailer;

has timer => (
    is      => "rw",
    default => 5,
);

has mailer => (
    is       => "ro",
    isa      => "VotoLegal::Mailer",
    default  => sub { VotoLegal::Mailer->new() },
);

has schema => (
    is       => "rw",
    required => 1,
);

sub listen_queue {
    my $self = shift;

    $self->logger->debug("Buscando itens na fila...") if $self->logger;

    my @items = $self->schema->resultset('EmailQueue')->search(
        { sent => 0 },
        {
            rows   => 20,
            for    => "update",
            column => [ qw(me.id me.body) ],
        },
    )->all;

    if (@items) {
        $self->logger->info(sprintf("'%d' itens serão processados.", scalar @items)) if $self->logger;

        for my $item (@items) {
            $self->exec_item($item);
        }

        $self->logger->info("Todos os items foram processados com sucesso") if $self->logger;
    }
    else {
        $self->logger->info("Não há itens pendentes na fila.") if $self->logger;
    }
}

sub run_once {
    my ($self, $item_id) = @_;

    my $item ;
    if (defined($item_id)) {
        $item = $self->schema->resultset('EmailQueue')->find($item_id);
    }
    else {
        $item = $self->schema->resultset('EmailQueue')->search(
            {
                sent => 0,
            },
            {
                rows   => 1,
                for    => "update",
                column => [ qw(me.id me.body) ],
            },
        )->next;
    }

    if ($item) {
        return $self->exec_item($item);
    }
    return 0;
}

sub exec_item {
    my ($self, $item) = @_;

    my $body = $item->body;

    if ($self->mailer->send($body)) {
        $item->delete();
        return 1;
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;
