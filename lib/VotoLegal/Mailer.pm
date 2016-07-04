package VotoLegal::Mailer;
use Moose;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;

BEGIN {
    if (!$ENV{HARNESS_ACTIVE} && $0 !~ /forkprove/) {
        $ENV{VOTOLEGAL_SMTP_SERVER} || die "ENV 'VOTOLEGAL_SMTP_SERVER' MISSING";
        $ENV{VOTOLEGAL_SMTP_USER}   || die "ENV 'VOTOLEGAL_SMTP_USER' MISSING";
        $ENV{VOTOLEGAL_SMTP_PASSWD} || die "ENV 'VOTOLEGAL_SMTP_PASSWD' MISSING";
        $ENV{VOTOLEGAL_SMTP_PORT}   || die "ENV 'VOTOLEGAL_SMTP_PORT' MISSING";
    }
}

has from => (
    is      => "ro",
    default => 'no-reply@votolegal.org'
);

has transport => (
    is         => "ro",
    lazy_build => 1,
);

sub _build_transport {
    return Email::Sender::Transport::SMTP::TLS->new(
        helo     => "votolegal",
        host     => $ENV{VOTOLEGAL_SMTP_SERVER},
        timeout  => 20,
        port     => $ENV{VOTOLEGAL_SMTP_PORT},
        username => $ENV{VOTOLEGAL_SMTP_USER},
        password => $ENV{VOTOLEGAL_SMTP_PASSWD},
    );
}

sub send {
    my ($self, $email) = @_;

    if ($ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/) {
        return 1;
    }

    sendmail($email, { from => $self->from, transport => $self->transport });
}

__PACKAGE__->meta->make_immutable;

1;
