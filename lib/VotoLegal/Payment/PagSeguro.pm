package VotoLegal::Payment::PagSeguro;
use common::sense;
use Moose;

with 'VotoLegal::Payment';

use Carp;
use Furl;
use XML::Simple;
use IO::Socket::SSL;

has merchant_id => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has merchant_key => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has sandbox => (
    is       => "rw",
    isa      => "Bool",
    required => 1,
);

has ua => (
    is      => "rw",
    isa     => "Furl",
    default => sub {
        Furl->new(
            ssl_opts => { SSL_verify_mode => SSL_VERIFY_NONE },
        )
    },
    lazy => 1,
);

has logger => (
    is => "rw",
);

sub endpoint {
    my ($self) = @_;

    my $endpoint = $self->sandbox
        ? "https://ws.sandbox.pagseguro.uol.com.br/v2/"
        : "https://ws.pagseguro.uol.com.br/v2/";

    return $endpoint;
}

sub createSession {
    my ($self) = @_;

    my $req = $self->ua->post(
        $self->endpoint . "sessions",
        [],
        {
            email => $self->merchant_id,
            token => $self->merchant_key,
        }
    );

    $self->logger->info("PagSeguro session: " . $req->content) if $self->logger;

    if ($req->is_success()) {
        my $xml = XMLin($req->content);

        if (ref $xml) {
            return $xml;
        }
    }

    return ;
}

sub transaction {
    my ($self, %args) = @_;

    my $req = $self->ua->post(
        $self->endpoint . "transactions/",
        [],
        {
            %args,
            email                  => $self->merchant_id,
            token                  => $self->merchant_key,
            paymentMode            => "default",
            receiverEmail          => $self->merchant_id,
            currency               => "BRL",
            shippingAddressCountry => "BRA",
            billingAddressCountry  => "BRA",
        }
    );

    $self->logger->info("PagSeguro transaction: " . $req->content) if $self->logger;

    if ($req->is_success()) {
        return XMLin($req->content);
    }

    return ;
}

sub notification {
    my ($self, $notificationCode) = @_;

    defined $notificationCode or die "missing 'notification code'.";

    my $req = $self->ua->get(
        $self->endpoint
        . "transactions/notifications/"
        . $notificationCode
        . "?email="
        . $self->merchant_id
        . "&token="
        . $self->merchant_key
    );

    $self->logger->info("PagSeguro notification: " . $req->content) if $self->logger;

    if ($req->is_success()) {
        return XMLin($req->content);
    }

    return ;
}

__PACKAGE__->meta->make_immutable;

1
