package VotoLegal::Mailer::Template;
use Moose;
use Template::Tiny;

use namespace::autoclean;
use MIME::Lite;
use DateTime;
use Encode;

has content => (is => 'ro');
has to      => (is => 'ro');
has title   => (is => 'ro');

has cc      => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] }
);

has subject => (is => 'ro');
has from    => (is => 'ro');

sub build_email {
    my ($self, $fixed_to) = @_;

    ref $self->to or die "'to' param must be a Result::User";

    my $to = $self->to->email;
    $to    = $fixed_to if defined $fixed_to;

    my $email = MIME::Lite->new(
        To      => Encode::encode('MIME-Header', $to),
        Subject => Encode::encode('MIME-Header', $self->subject),
        Type    => q{multipart/related},
        From    => $self->from,
    );

    return $email;
}

__PACKAGE__->meta->make_immutable;

1;

