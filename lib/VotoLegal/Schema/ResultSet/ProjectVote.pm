package VotoLegal::Schema::ResultSet::ProjectVote;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                donation_id => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r           = shift;
                        my $donation_id = $r->get_value('donation_id');

                        length($donation_id) == 32 or return 0;

                        $self->result_source->schema->resultset('Donation')->find($donation_id);
                    },
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

