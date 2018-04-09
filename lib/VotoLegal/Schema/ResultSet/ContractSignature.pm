package VotoLegal::Schema::ResultSet::ContractSignature;
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
                user_id => {
                    required   => 1,
                    type       => 'Int',
                    post_check => sub {
                        my $user_id = $_[0]->get_value('user_id');

                        die \['user_id', 'alredy signed contract'] if $self->search( { user_id => $user_id } )->next;

                        return 1;
                    }
                },
                ip_address => {
                    required => 1,
                    type     => 'Str',
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
