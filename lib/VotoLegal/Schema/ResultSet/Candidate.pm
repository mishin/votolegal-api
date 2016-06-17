package VotoLegal::Schema::ResultSet::Candidate;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';
with 'VotoLegal::Role::Verification::TransactionalActions::DBIC';

use Business::BR::CEP qw(test_cep);
use VotoLegal::Types qw(CPF);
use MooseX::Types::Email qw(EmailAddress);

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                email => {
                    required => 1,
                    type     => EmailAddress,
                    post_check => sub {
                        my $r = shift;

                        $self->result_source->schema->resultset('User')->search({
                            email => $r->get_value('email'),
                        })->count and die \["email", "already exists"];

                        return 1;
                    }
                },
                password => {
                    required => 1,
                    type     => 'Str',
                },
                username => {
                    required => 1,
                    type     => 'Str',
                    post_check => sub {
                        my $r = shift;

                        $self->search({
                            username => $r->get_value('username'),
                        })->count and die \["username", "already exists"];

                        return 1;
                    },
                },
                name => {
                    required => 1,
                    type     => 'Str',
                },
                popular_name => {
                    required => 1,
                    type     => 'Str',
                },
                party_id => {
                    required   => 1,
                    type       => 'Int',
                    post_check => sub {
                        my $r        = shift;
                        my $party_id = $r->get_value('party_id');

                        $self->result_source->schema->resultset('Party')->search({ id => $party_id })->count;
                    },
                },
                cpf => {
                    required   => 1,
                    type       => CPF,
                    post_check => sub {
                        my $r = shift;

                        $self->search({
                            cpf => $r->get_value('cpf'),
                        })->count and die \["cpf", "already exists"];

                        return 1;
                    },
                },
                office_id => {
                    required   => 1,
                    type       => 'Int',
                    post_check => sub {
                        my $r         = shift;
                        my $office_id = $r->get_value('office_id');

                        $self->result_source->schema->resultset('Office')->search({ id => $office_id })->count;
                    },
                },
                status => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $status = $r->get_value('status');
                        $status =~ m{^(pending|activated|deactivated)$};
                    }
                },
                reelection => {
                    required   => 1,
                    type       => 'Bool',
                },
                address_state => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $state = $r->get_value('address_state');
                        $self->result_source->schema->resultset('State')->search({ name => $state })->count;
                    },
                },
                address_city => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $city = $r->get_value('address_city');
                        $self->result_source->schema->resultset('City')->search({ name => $city })->count;
                    },
                },
                address_zipcode => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $cep = $r->get_value('address_zipcode');
                        return test_cep($cep);

                    },
                },
                address_street => {
                    required   => 1,
                    type       => 'Str',
                },
                address_house_number => {
                    required   => 1,
                    type       => 'Int',
                },
                address_complement => {
                    required   => 0,
                    type       => 'Str',
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

            # Creating user.
            my %user;
            $user{$_} = delete $values{$_} for qw(email password);

            my $user = $self->result_source->schema->resultset('User')->create(\%user);
            $user->add_to_roles({ id => 2 });

            # Creating candidate.
            my $candidate = $user->candidates->create(\%values);

            return $candidate;
        },
    };
}


1;