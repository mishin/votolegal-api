package VotoLegal::Worker::Slack;
use common::sense;
use Moose;

with 'VotoLegal::Worker';

use WebService::Slack::IncomingWebHook;

has timer => (
    is      => "rw",
    default => 30,
);

has slack => (
    is         => "rw",
    isa        => "WebService::Slack::IncomingWebHook",
    lazy_build => 1,
);

has schema => (
    is       => "rw",
    required => 1,
);

sub listen_queue {
    my $self = shift;

    $self->logger->debug("Buscando itens na fila...") if $self->logger;

    my @items = $self->schema->resultset('SlackQueue')->search(
        {},
        { rows => 20 },
    )->all;

    if (@items) {
        $self->logger->info(sprintf("'%d' itens serão processados.", scalar @items)) if $self->logger;

        for my $item (@items) {
            $self->exec_item($item);
        }

        $self->logger->info("Todos os items foram processados com sucesso") if $self->logger;
    }
    else {
        $self->logger->debug("Não há itens pendentes na fila.") if $self->logger;
    }
}

sub run_once {
    my ($self, $item_id) = @_;

    my $item ;
    if (defined($item_id)) {
        $item = $self->schema->resultset('SlackQueue')->find($item_id);
    }
    else {
        $item = $self->schema->resultset('SlackQueue')->search(
            undef,
            {
                order_by => "created_at",
                rows     => 1,
            },
        )->next;
    }

    if (ref $item) {
        return $self->exec_item($item);
    }
    return 0;
}

sub exec_item {
    my ($self, $item) = @_;

    $self->logger->debug(sprintf("[#%s] %s", $item->channel, $item->message)) if $self->logger;

    # Parametrizando o 'channel'.
    $self->slack->{channel} = $item->channel;

    eval {
        $self->slack->post(text => $item->message);
    };

    if (!$@) {
        $item->delete();
        return 1;
    }

    return 0;
}

sub _build_slack {
    my $self = shift;

    return WebService::Slack::IncomingWebHook->new(%{ $self->config->{slack} });
}

__PACKAGE__->meta->make_immutable;

1;
