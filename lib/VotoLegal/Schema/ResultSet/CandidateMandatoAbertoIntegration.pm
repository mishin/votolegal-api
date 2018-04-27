package VotoLegal::Schema::ResultSet::CandidateMandatoAbertoIntegration;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                candidate_id => {
                    required   => 1,
                    type       => 'Int',
                },
                mandatoaberto_id => {
                    required => 1,
                    type     => 'Int',
                },
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            return $self->create(\%values);
        },
    };
}


1;
