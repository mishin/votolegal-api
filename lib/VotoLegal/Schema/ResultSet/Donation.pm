package VotoLegal::Schema::ResultSet::Donation;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;
use VotoLegal::Types qw(CPF);
use MooseX::Types::Email qw(EmailAddress);

sub resultset {
    my $self = shift;

    return $self->result_source->schema->resultset(@_);
}

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required => 1,
                    type     => "Str",
                },
                email => {
                    required => 1,
                    type     => EmailAddress,
                },
                cpf => {
                    required => 1,
                    type     => CPF,
                },
                phone => {
                    required => 0,
                    type     => "Str",
                },
                amount => {
                    required => 1,
                    type     => "Int",
                },
                candidate_id => {
                    required   => 1,
                    type       => "Int",
                    post_check => sub {
                        my $r = shift;

                        $self->resultset('Candidate')->find($r->get_value('candidate_id'));
                    },
                },
                status => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        my $r = shift;

                        my $status = $r->get_value('status');
                        $status    =~ m{^(created|tokenized|authorized|captured)$};
                    },
                },
                credit_card_name => {
                    required => 1,
                    type     => "Str",
                },
                credit_card_validity => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        my $credit_card_validity = $_[0]->get_value('credit_card_validity');
                        $credit_card_validity =~ m{^[0-9]{6}$} or die \['credit_card_validity', "must be in AAAAMM format"]
                    },
                },
                credit_card_number => {
                    required => 1,
                    type     => "Str",
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
