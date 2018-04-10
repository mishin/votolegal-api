package VotoLegal::Mailer::Template;
use Moose;
use namespace::autoclean;

use Template;
use MIME::Lite;
use Encode;

use VotoLegal::Types qw(EmailAddress);

has to => (
    is       => 'ro',
    isa      => EmailAddress,
    required => 1,
);

has subject => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has from => (
    is       => 'ro',
    isa      => EmailAddress,
    required => 1,
);

has template => (
    is       => "ro",
    isa      => "Str",
    required => 1,
);

has vars => (
    is       => "ro",
    isa      => "HashRef",
    default  => sub { {} },
);

sub build_email {
    my ($self) = @_;

    my $tt = Template->new(EVAL_PERL => 0);

    my $content ;
    $tt->process(
        \$self->template,
        $self->vars,
        \$content,
    );

    my $email = MIME::Lite->new(
        To       => $self->to,
        Subject  => Encode::encode("MIME-Header", $self->subject),
        From     => $self->from,
        Type     => "text/html",
        Data     => $content,
        Encoding => 'base64',
    );

    return $email;
}

__PACKAGE__->meta->make_immutable;

1;

