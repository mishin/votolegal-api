package VotoLegal::Schema::ResultSet::Candidate;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use VotoLegal::Types qw(CPF);

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required => 1,
                    type     => 'Str',
                },
                popular_name => {
                    required => 1,
                    type     => 'Str',
                },
                raising_goal => {
                    required => 1,
                    type     => 'Int',
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
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        create => sub { 1 },
    };
}


1;
