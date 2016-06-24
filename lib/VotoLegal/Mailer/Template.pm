package VotoLegal::Mailer::Template;
use Moose;
use namespace::autoclean;

use Template;
use MIME::Lite;
use Encode;

has to => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has subject => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has from => (
    is       => 'ro',
    isa      => 'Str',
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
        To      => Encode::encode("MIME-Header", $self->to),
        Subject => Encode::encode("MIME-Header", $self->subject),
        Type    => "multipart/related",
        From    => $self->from,
    );

    $email->attach(
        Type => "text/html",
        Data => $content,
    );

    return $email;
}

__PACKAGE__->meta->make_immutable;

1;

