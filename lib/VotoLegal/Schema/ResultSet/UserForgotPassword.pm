package VotoLegal::Schema::ResultSet::UserForgotPassword;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';
with 'VotoLegal::Role::Verification::TransactionalActions::DBIC';

use MooseX::Types::Email qw(EmailAddress);

use Data::Verifier;
use Digest::SHA1 qw(sha1_hex);
use Time::HiRes;
use Data::Printer;

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
                        })->count;
                    }
                },
            }
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

            my $email = $values{email};
            my $user  = $self->result_source->schema->resultset('User')->search({ email => $email })->next;

            my $forgot_password = $self->create({
                user        => $user,
                token       => sha1_hex(Time::HiRes::time()),
                valid_until => \"(NOW() + '1 days'::interval)",
            });

            $user->send_email_forgot_password($forgot_password->token);

            return $forgot_password;
        },
    };
}


1;
