package VotoLegal::Schema::ResultSet::User;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;
use VotoLegal::Types qw(EmailAddress);

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                username => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        $self->search(
                            {
                                username => $r->get_value('username'),
                            }
                          )->count
                          and die \[ "username", "already exists" ];

                        return 1;
                    },
                },
                email => {
                    required   => 1,
                    type       => EmailAddress,
                    post_check => sub {
                        my $r = shift;

                        $self->search(
                            {
                                email => $r->get_value('email'),
                            }
                          )->count
                          and die \[ "email", "already exists" ];

                        return 1;
                    }
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

    return { create => sub { 1 }, };
}

1;
