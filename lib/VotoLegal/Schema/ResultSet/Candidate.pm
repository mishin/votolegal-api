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
                    required => 1,
                    type     => 'Int',
                },
                cpf => {
                    required => 1,
                    type     => CPF,
                },
                ficha_limpa => {
                    required => 1,
                    type     => 'Bool',
                },
                reelection => {
                    required => 1,
                    type     => 'Bool',
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
