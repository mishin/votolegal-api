package VotoLegal::Schema::ResultSet::VotolegalDonation;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;
use Business::BR::CEP qw(test_cep);
use VotoLegal::Types qw(EmailAddress CPF);
use VotoLegal::Utils;

use UUID::Tiny qw/is_uuid_string/;

sub resultset {
    my $self = shift;

    return $self->result_source->schema->resultset(@_);
}

sub verifiers_specs {
    my $self = shift;

    return {
        search => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                device_authorization_token_id => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        my $v = $_[0]->get_value('device_authorization_token_id');
                        return is_uuid_string($v);
                    },
                },
                donation_id => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        return is_uuid_string( $_[0]->get_value('donation_id') );
                    },
                },
            }
        ),
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
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        $_[0]->get_value('phone') =~ m{^[0-9]{10,11}$};
                    },
                },
                address_street => {
                    required => 1,
                    type     => "Str",
                },
                address_house_number => {
                    required => 1,
                    type     => "Int",
                },
                address_district => {
                    required => 1,
                    type     => "Str",
                },
                address_zipcode => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        test_cep( $_[0]->get_value('address_zipcode') );
                    },
                },
                address_city => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('address_city');
                        $self->resultset('City')->search( { name => $city } )->count;
                    },
                },
                address_state => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('address_state');
                        $self->resultset('State')->search( { code => $state } )->count;
                    },
                },
                address_complement => {
                    required => 0,
                    type     => 'Str',
                },
                amount => {
                    required   => 1,
                    type       => "Int",
                    post_check => sub {
                        my $amount = $_[0]->get_value('amount');

                        return 0 if $amount < 3000;

                        my $pm = $_[0]->get_value('payment_method');

                        if ( $pm eq 'credit_card' && $amount > 106400 ) {
                            return 0;
                        }

                        return 1;
                    },
                },
                credit_card_name => {
                    required => 0,
                    type     => "Str",
                },
                birthdate => {
                    required => 1,
                    type     => "Str",
                },
                billing_address_street => {
                    required => 0,
                    type     => "Str",
                },
                billing_address_house_number => {
                    required => 0,
                    type     => "Int",
                },
                billing_address_district => {
                    required => 0,
                    type     => "Str",
                },
                billing_address_zipcode => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        test_cep( $_[0]->get_value('billing_address_zipcode') );
                    },
                },
                billing_address_city => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('billing_address_city');
                        $self->resultset('City')->search( { name => $city } )->count;
                    },
                },
                billing_address_state => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('billing_address_state');
                        $self->resultset('State')->search( { code => $state } )->count;
                    },
                },
                billing_address_complement => {
                    required => 0,
                    type     => "Str",
                },
                ip_address => {
                    required => 1,
                    type     => "Str",
                },
                device_authorization_token_id => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        my $v = $_[0]->get_value('device_authorization_token_id');
                        $self->resultset('DeviceAuthorizationToken')->search( { id => $v, verified => 1 } )->count;
                    },
                },
                candidate_id => {
                    required => 1,
                    type     => "Int",
                },
                payment_method => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        $_[0]->get_value('payment_method') =~ /^(credit_card|boleto)$/;
                    },
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

            # padroniza cpf
            $values{$_} =~ s/[^0-9]//go for qw/cpf/;
            $values{$_} = lc $values{$_} for qw/email/;

            $self->_refuse_duplicate( map { $_ => $values{$_} } qw/cpf amount candidate_id/ );

            my $config = $self->_get_candidate_config( candidate_id => $values{candidate_id} );

            my $donation = $self->_create_donation( config => $config, values => \%values );

            return $donation;
        },
        search => sub {
            my $r = shift;

            my %values = $r->valid_values;

            my $donation = $self->search(
                {
                    id                            => $values{donation_id},
                    device_authorization_token_id => $values{device_authorization_token_id},
                }
            )->next;
            die_with 'donation-not-found' unless $donation;

            return $donation;
        },
    };
}

sub _create_donation {
    my ( $self, %opts ) = @_;

    die 'transaction_depth is wrong' unless $self->result_source->storage->transaction_depth == is_test ? 1 : 0;

    my %values    = %{ $opts{values} };
    my $config    = $opts{config};
    my $is_boleto = $values{payment_method} eq 'boleto';
    my $schema    = $self->result_source->schema;

    my $donation;
    $schema->txn_do(
        sub {
            $self->resultset('CpfLock')->find_or_create(
                {
                    cpf => $values{cpf},
                }
            );

            $donation = $self->create(
                {
                    is_boleto => $is_boleto ? 1 : 0,
                    candidate_id                  => $values{candidate_id},
                    device_authorization_token_id => $values{device_authorization_token_id},
                    is_pre_campaign               => $config->{is_pre_campaign} ? 1 : 0,
                    payment_gateway_id            => $config->{payment_gateway_id},
                }
            );

            my $donation_immu = $donation->new_related(
                'votolegal_donation_immutable',
                {
                    donation_type_id => $config->{donation_type_id},
                    amount           => $values{amount},

                    donor_name      => $values{name},
                    donor_email     => $values{email},
                    donor_cpf       => $values{cpf},
                    donor_phone     => $values{phone},
                    donor_birthdate => $values{birthdate},

                    address_state                => $values{address_state},
                    address_city                 => $values{address_city},
                    address_district             => $values{address_district},
                    address_zipcode              => $values{address_zipcode},
                    address_street               => $values{address_street},
                    address_complement           => $values{address_complement},
                    address_house_number         => $values{address_house_number},
                    billing_address_street       => $values{billing_address_street},
                    billing_address_house_number => $values{billing_address_house_number},
                    billing_address_district     => $values{billing_address_district},
                    billing_address_zipcode      => $values{billing_address_zipcode},
                    billing_address_city         => $values{billing_address_city},
                    billing_address_state        => $values{billing_address_state},
                    billing_address_complement   => $values{billing_address_complement},

                    started_ip_address => $values{ip_address},
                }
            )->insert;
        }
    );

    return $donation;
}

sub _get_candidate_config {
    my ($self) = @_;

    # TODO carregar do banco isso, de acordo com a tabela de config de campanha
    return {
        donation_type_id   => 1,    #PF
        is_pre_campaign    => 1,
        payment_gateway_id => 3,
      }

}

sub _refuse_duplicate {
    my ( $self, %values ) = @_;

    # Buscando uma possível doação repetida. Se aconteceu há menos de 30sec, travamos o processo.
    my $repeatedDonation = $self->search(
        {
            candidate_id                             => $values{candidate_id},
            'votolegal_donation_immutable.donor_cpf' => $values{cpf},
            'votolegal_donation_immutable.amount'    => $values{amount},
            created_at                               => { ">=" => \"(now() - '30 seconds'::interval)" },
        },
        {
            join => 'votolegal_donation_immutable'

        }
    )->next;

    if ($repeatedDonation) {
        die_with 'donation-repeated';
    }
}

1;

