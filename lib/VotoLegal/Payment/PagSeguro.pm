package VotoLegal::Payment::PagSeguro;
use common::sense;
use Moose;

with 'VotoLegal::Payment';

use Carp;
use Furl;
use XML::Simple;
use XML::Hash::XS qw/ hash2xml /;
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
    my ($self, $action) = @_;

    die \['action', 'invalid'] unless $action =~ m{^(transaction|notification|session)$};

    # A API do PagSeguro atualmente (11/04/2018)
    # possui seu endpoint de transação e sessão
    # na v2 e o endpoint de consulta de notificação no v3

    my $endpoint = $self->sandbox
        ? ( $action eq 'transaction' || $action eq 'session' ? "https://ws.sandbox.pagseguro.uol.com.br/v2/" : "https://ws.sandbox.pagseguro.uol.com.br/v3/")
        : ( $action eq 'transaction' || $action eq 'session' ? "https://ws.pagseguro.uol.com.br/v2/"         : "https://ws.pagseguro.uol.com.br/v3/" );

    return $endpoint;
}

sub createSession {
    my ($self) = @_;

    my $action = 'session';

    my $req = $self->ua->post(
        $self->endpoint($action) . "sessions",
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
    my ($self, $args) = @_;

    my $merchant_id  = $self->merchant_id;
    my $merchant_key = $self->merchant_key;

    my $action = 'transaction';

    my $req = $self->ua->post(
        $self->endpoint($action) . "transactions/?email=$merchant_key&token=$merchant_key",
        [ 'Content-Type', 'application/xml' ],
        $args
    );

    $self->logger->info("PagSeguro transaction: " . $req->content) if $self->logger;

    if ($req->is_success()) {
        return XMLin($req->content);
    }

    return ;
}

sub notification {
    my ($self, $notificationCode) = @_;

    my $action = 'transaction';

    defined $notificationCode or die "missing 'notification code'.";

    my $req = $self->ua->get(
        $self->endpoint($action)
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
