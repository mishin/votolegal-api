package VotoLegal::Schema::ResultSet::Payment;
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
                    post_check => sub {
                        my $candidate_id = $_[0]->get_value('candidate_id');

                        die \['candidate_id', "can't find candidate with that id"]
                            unless $self->result_source->schema->resultset('Candidate')->search( { id => $candidate_id } );

                        return 1;
                    }
                },
                method => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $method = $_[0]->get_value('method');

                        die \['method', "must be 'creditCard' or 'boleto'"] unless $method =~ m{^(creditCard|boleto)$};

                        return 1;
                    }
                },
                sender_hash => {
                    required => 1,
                    type     => "Str"
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

            my $payment = $self->create(\%values);

            return $payment;
        },
    };
}

1;
