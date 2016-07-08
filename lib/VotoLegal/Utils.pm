package VotoLegal::Utils;
use common::sense;

=encoding UTF-8

=head1 NAME

VotoLegal::Utils

=cut

use vars qw(@ISA @EXPORT);

@ISA    = (qw(Exporter));
@EXPORT = qw(is_test);

=head1 METHODS

=head2 is_test()

Retorna 1 caso esteja rodando em uma suíte de testes.

=cut

sub is_test {
    if ($ENV{HARNESS_ACTIVE} || $0 =~ m{forkprove}) {
        return 1;
    }
    return 0;
}

=head1 AUTHOR

Junior Moraes L<juniorfvox@gmail.com|mailto:juniorfvox@gmail.com>.

=cut

1;
