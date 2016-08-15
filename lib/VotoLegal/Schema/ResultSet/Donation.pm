package VotoLegal::Schema::ResultSet::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Time::HiRes;
use Digest::MD5 qw(md5_hex);
use Data::Verifier;
use Date::Calc qw(check_date);
use Business::BR::CEP qw(test_cep);
use VotoLegal::Types qw(EmailAddress CPF);
use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

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
                merchant_id => {
                    required => 1,
                    type     => "Str",
                },
                merchant_key => {
                    required => 1,
                    type     => "Str",
                },
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
                    required => 1,
                    type     => "Str",
                    post_check => sub {
                        $_[0]->get_value('phone') =~ m{^\d{10,11}$};
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
                        test_cep($_[0]->get_value('address_zipcode'));
                    },
                },
                address_city => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('address_city');
                        $self->resultset('City')->search({ name => $city })->count;
                    },
                },
                address_state => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('address_state');
                        $self->resultset('State')->search({ code => $state })->count;
                    },
                },
                sender_hash => {
                    required => 1,
                    type     => "Str",
                },
                credit_card_token => {
                    required => 1,
                    type     => "Str",
                },
                amount => {
                    required => 1,
                    type     => "Int",
                },
                credit_card_name => {
                    required => 1,
                    type     => "Str",
                },
                birthdate => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        my $birthdate = $_[0]->get_value("birthdate");

                        my @date = $birthdate =~ /^(\d{4})-(\d{2})-(\d{2})$/;
                        check_date(@date);
                    },
                },
                billing_address_street => {
                    required => 1,
                    type     => "Str",
                },
                billing_address_house_number => {
                    required => 1,
                    type     => "Int",
                },
                billing_address_district => {
                    required => 1,
                    type     => "Str",
                },
                billing_address_zipcode => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        test_cep($_[0]->get_value('billing_address_zipcode'));
                    },
                },
                billing_address_city => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('billing_address_city');
                        $self->resultset('City')->search({ name => $city })->count;
                    },
                },
                billing_address_state => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('billing_address_state');
                        $self->resultset('State')->search({ code => $state })->count;
                    },
                },
                billing_address_complement => {
                    required => 1,
                    type     => "Str",
                },
                receipt_id => {
                    required => 1,
                    type     => "Int",
                },
                ip_address => {
                    required => 1,
                    type     => "Str",
                },
                candidate_id => {
                    required => 1,
                    type     => "Int",
                },
                notification_url => {
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

            # Driver do PagSeguro.
            my $pagseguro = VotoLegal::Payment::PagSeguro->new(
                merchant_id  => delete $values{merchant_id},
                merchant_key => delete $values{merchant_key},
                sandbox      => is_test(),
            );

            # Tratando alguns dados.
            my $id          = md5_hex(Time::HiRes::time());
            my $phone       = $values{phone};
            my $phoneDDD    = substr($values{phone}, 0, 2);
            my $phoneNumber = substr($values{phone}, 2);
            my $amount      = sprintf("%.2f", $values{amount} / 100);
            my $birthdate   = $values{birthdate};
            my $zipcode     = $values{address_zipcode};
            $zipcode        =~ s/\D//g;

            my $cpf = $values{cpf};
            $cpf    =~ s/\D//g;

            if ($birthdate =~ /^(\d{4})-(\d{2})-(\d{2})$/) {
                $birthdate = sprintf("%02d/%02d/%04d", $3, $2, $1);
            }

            my $req = $pagseguro->transaction(
                itemQuantity1             => 1,
                itemId1                   => "2",
                paymentMethod             => "creditCard",
                itemDescription1          => "Doação VotoLegal",
                itemAmount1               => $amount,
                reference                 => $id,
                senderName                => $values{name},
                senderCPF                 => $cpf,
                senderAreaCode            => $phoneDDD,
                senderPhone               => $phoneNumber,
                senderEmail               => $values{email},
                shippingAddressStreet     => $values{address_street},
                shippingAddressNumber     => $values{address_house_number},
                shippingAddressDistrict   => $values{address_district},
                shippingAddressPostalCode => $zipcode,
                shippingAddressCity       => $values{address_city},
                shippingAddressState      => $values{address_state},
                senderHash                => $values{sender_hash},
                creditCardToken           => $values{credit_card_token},
                installmentQuantity       => 1,
                installmentValue          => $amount,
                creditCardHolderName      => $values{credit_card_name},
                creditCardHolderCPF       => $cpf,
                creditCardHolderBirthDate => $birthdate,
                creditCardHolderAreaCode  => $phoneDDD,
                creditCardHolderPhone     => $phoneNumber,
                billingAddressStreet      => $values{billing_address_street},
                billingAddressNumber      => $values{billing_address_house_number},
                billingAddressComplement  => $values{billing_address_complement},
                billingAddressDistrict    => $values{billing_address_district},
                billingAddressPostalCode  => $values{billing_address_zipcode},
                billingAddressCity        => $values{billing_address_city},
                billingAddressState       => $values{billing_address_state},
                notificationURL           => $values{notification_url},
            );

            return $self->create({
                id           => $id,
                candidate_id => $values{candidate_id},
                name         => $values{name},
                email        => $values{email},
                cpf          => $values{cpf},
                phone        => $values{phone},
                amount       => $values{amount},
                birthdate    => $values{birthdate},
                receipt_id   => $values{receipt_id},
                ip_address   => $values{ip_address},
                status       => "created",
            });
        },
    };
}

1;
