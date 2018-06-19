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
                    required => 1,
                    type     => 'Int',
                },
                mandatoaberto_id => {
                    required => 1,
                    type     => 'Int',
                },
                page_id => {
                    required => 1,
                    type     => 'Str'
                }
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

            my $existent_candidate_mandatoaberto_integration = $self->search(
                { candidate_id => $values{candidate_id} }
            )->next;

            if (!defined $existent_candidate_mandatoaberto_integration) {
                my $candidate_mandatoaberto_integration = $self->create(\%values);

                return $candidate_mandatoaberto_integration;
            } else {
                my $updated_candidate_mandatoaberto_integration = $existent_candidate_mandatoaberto_integration->update(\%values);

                return $updated_candidate_mandatoaberto_integration;
            }
        },
    };
}

1;
