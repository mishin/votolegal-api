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
                        my $user_id         = $_[0]->get_value('user_id');
                        my $is_pre_campaign = $_[0]->get_value('is_pre_campaign');

                        die \[ 'user_id', 'alredy signed contract' ] if $self->search(
                            {
                                user_id         => $user_id,
                                is_pre_campaign => $is_pre_campaign
                            }
                        )->next;

                        return 1;
                    }
                },
                ip_address => {
                    required => 1,
                    type     => 'Str',
                },
                is_pre_campaign => {
                    required => 1,
                    type     => 'Bool'
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

            my $contract_signature = $self->create( \%values );

            $contract_signature->user->send_email_contract_signed();

            return $contract_signature;
        },
    };
}

1;
