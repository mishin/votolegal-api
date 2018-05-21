package VotoLegal::Schema::ResultSet::PaymentNotification;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        upsert => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                notification_code => {
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
        upsert => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            my $notification = $self->search( { notification_code => $values{notification_code} } )->next;

            $notification = $self->create( \%values ) unless $notification;

            return $notification;
        },
    };
}

1;
