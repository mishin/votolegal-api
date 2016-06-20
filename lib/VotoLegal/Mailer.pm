package VotoLegal::Mailer;
use Moose;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;

BEGIN {
    if (!$ENV{HARNESS_ACTIVE} && !$0 =~ /forkprove/) {
        defined $ENV{VOTOLEGAL_SMTP_SERVER} or die "ENV 'VOTOLEGAL_SMTP_SERVER' MISSING";
        defined $ENV{VOTOLEGAL_SMTP_USER}   or die "ENV 'VOTOLEGAL_SMTP_USER' MISSING";
        defined $ENV{VOTOLEGAL_SMTP_PASSWD} or die "ENV 'VOTOLEGAL_SMTP_PASSWD' MISSING";
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
        port     => 587,
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
