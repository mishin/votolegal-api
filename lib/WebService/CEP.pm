package WebService::CEP;

use Moose;
with 'MooseX::Traits';

use Moose::Util::TypeConstraints qw(duck_type);
has '+_trait_namespace' => ( default => __PACKAGE__ );

has cache => ( is => 'ro', required => 0, predicate => 'has_cache' );

# has backend => (
#   is      => 'ro',
#   lazy    => 1,
#   required => 1,
#   builder => '_build_backend',
#   isa     => duck_type( [qw(find)] )
# );

sub find {
    my ( $self, $cep ) = @_;

    $cep =~ s/[^0-9]//go;

    return $self->cache->compute(
        $cep, undef,
        sub {
            $self->_find($cep);
        }
    ) if $self->has_cache;

    return $self->_find($cep);
}

1;
