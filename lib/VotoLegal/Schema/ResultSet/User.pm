package VotoLegal::Schema::ResultSet::User;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;
use MooseX::Types::Email qw(EmailAddress);

sub verifiers_specs {
    my $self = shift;

    return {
        login => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                username => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub { 1 }
                },
                password => {
                    required => 1,
                    type     => 'Str',
                },
            },
        ),
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                username => {
                    required => 1,
                    type     => 'Str',
                },
                email => {
                    required   => 1,
                    type       => EmailAddress,
                    post_check => sub { 1 }
                },
                password => {
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
        login  => sub { 1 },
        create => sub { 1 },
    };
}


1;
