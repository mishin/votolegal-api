#<<<
use utf8;
package VotoLegal::Schema::Result::Payment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("payment");
__PACKAGE__->add_columns(
  "code",
  { data_type => "text", is_nullable => 1 },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sender_hash",
  { data_type => "text", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "method",
  { data_type => "text", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "address_state",
  { data_type => "text", is_nullable => 1 },
  "address_city",
  { data_type => "text", is_nullable => 1 },
  "address_zipcode",
  { data_type => "text", is_nullable => 1 },
  "address_district",
  { data_type => "text", is_nullable => 1 },
  "address_street",
  { data_type => "text", is_nullable => 1 },
  "address_complement",
  { data_type => "text", is_nullable => 1 },
  "address_house_number",
  { data_type => "integer", is_nullable => 1 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "payment_id_seq",
  },
  "gross_amount",
  { data_type => "text", is_nullable => 1 },
  "net_amount",
  { data_type => "text", is_nullable => 1 },
  "fee_amount",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->has_many(
  "payment_logs",
  "VotoLegal::Schema::Result::PaymentLog",
  { "foreign.payment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-07-04 16:32:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IY+L/P+Wh7htgFVknzKjhw

# You can replace this text with custom code or comments, and it will be preserved on regeneration

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;
use VotoLegal::Dieable;
use WebService::IuguForReal;

use JSON::MaybeXS;
use XML::Hash::XS qw/ hash2xml /;

sub send_pagseguro_transaction {
    my ( $self, $credit_card_token, $log ) = @_;

    my $xs = XML::Hash::XS->new( utf8 => 0, encoding => 'utf-8' );

    my $merchant_id  = $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID};
    my $merchant_key = $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY};

    my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $merchant_id,
        merchant_key => $merchant_key,
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX},
        logger       => $log,
    );

    my $candidate = $self->candidate;

    my $sender       = $self->build_sender_object();
    my $item         = $self->build_item_object();
    my $shipping     = $self->build_shipping_object();
    my $creditCard   = $self->build_credit_card_object($credit_card_token);
    my $callback_url = $self->build_callback_url('pagseguro');
    my $payment_args = {
        mode            => "default",
        currency        => 'BRL',
        method          => $self->method,
        sender          => $sender,
        items           => $item,
        shipping        => $shipping,
        reference       => $candidate->id,
        extraAmount     => "0.00",
        notificationURL => $callback_url,
        creditCard      => $creditCard ? $creditCard : ()
    };

    $payment_args = $xs->hash2xml( $payment_args, root => 'payment' );

    # Criando entrada no log
    $self->result_source->schema->resultset("PaymentLog")->create(
        {
            payment_id => $self->id,
            status     => 'sent'
        }
    );

    my $payment = $pagseguro->transaction($payment_args);

    return $payment;
}

sub create_and_capture_iugu_invoice {
    my ($self, $credit_card_token) = @_;

    my $gateway = WebService::IuguForReal->instance();

    my $is_boleto = $self->method eq 'boleto' ? 1 : 0;
    my $candidate = $self->candidate;
    my $document  = $candidate->campaign_donation_type eq 'pre-campaign' ? $candidate->cpf : $candidate->cnpj;

	my $candidate_due_date = $self->result_source->schema->resultset('Candidate')->search(
		{
			id => $self->candidate_id

		},
		{
			'+columns' => [
				{
					due_date => \"timezone('America/Sao_Paulo', now())::date + '5 days'::interval"
				}
			]
		}
	)->next;

	my $due_date = $candidate_due_date->get_column('due_date');

    my $invoice = $gateway->create_invoice(
        is_votolegal_payment => 1,
        credit_card_token    => $credit_card_token,
        due_date             => $due_date,
        amount               => $self->get_license_value_in_cents(),
        is_boleto            => $is_boleto,
        description          => 'Pagamento Voto Legal',
        candidate_id         => $self->candidate_id,
		payer => {
			cpf_cnpj => $document,
			name     => $candidate->name,
			address  => {
				state    => $self->address_state,
				city     => $self->address_city,
				district => $self->address_district,
				zip_code => $self->address_zipcode,
				street   => $self->address_street,
				number   => $self->address_house_number,
			}
		},

        ( $is_boleto ? ( notification_url => $self->build_callback_url('iugu') ) : () )
    );

    if ( $invoice->{_charge_response_} && $invoice->{_charge_response_}{'success'} eq 'false' ) {
        die \['message', 'transaction not authorized, check your data.'] ;
    }

    $self->update( { code => $invoice->{id} } );

	$self->result_source->schema->resultset("PaymentLog")->create(
		{
			payment_id => $self->id,
			status     => 'sent'
		}
	);

    my $payment_execution;
    my $ret;
    if ( !$is_boleto ) {
		$payment_execution = $gateway->capture_invoice(
            is_votolegal_payment => 1,
			id                   => $invoice->{id},
			candidate_id         => $self->candidate_id
		);
        die_with 'payment not authorized' unless $payment_execution->{status} eq 'paid';

        if ( $payment_execution->{status} eq 'paid' ) {
            $candidate->update(
                {
                    status         => 'activated',
                    payment_status => 'paid'
                }
            );

			$self->result_source->schema->resultset("PaymentLog")->create(
				{
					payment_id => $self->id,
					status     => 'captured'
				}
			);
        } else {
			$self->result_source->schema->resultset("PaymentLog")->create(
				{
					payment_id => $self->id,
					status     => 'failed'
				}
			);

        }

        $ret = $payment_execution;
    }
    else {
		$self->result_source->schema->resultset("PaymentLog")->create(
			{
				payment_id => $self->id,
				status     => 'analysis'
			}
		);

        $ret = $invoice;
    }

    return $ret;
}

sub build_callback_url {
    my ($self, $gateway) = @_;

    my $callback_url;
    if ($gateway eq 'pagseguro') {
        $callback_url = $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL};
        $callback_url .= "/" unless $callback_url =~ m{\/$};
        $callback_url .= "api3/pagseguro";
    }
    else {
		$callback_url = $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL};
		$callback_url .= "/" unless $callback_url =~ m{\/$};
		$callback_url .= "api3/iugu";
    }


    return $callback_url;
}

sub build_sender_object {
    my ($self) = @_;

    # No pré-cadastro colhemos apenas
    # o CPF, logo não é necessário
    # criar uma lógica que verifique
    # o document que o candidato possui
    # e seu respectivo type
    my $document = {
        document => {
            type  => 'CPF',
            value => $self->candidate->cpf
        }
    };

    # A API do Pagseguro, por algum motivo, requer em sandbox
    # que o xml tenha o formato '<sender><senderHash></senderHash></sender>'
    # e em prod '<sender><senderHash></senderHash></sender>'
    my $ret;

    if ( $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX} ) {
        $ret = {
            senderHash => $self->sender_hash,
            name       => $self->name,
            phone      => $self->build_phone_object(),
            email      => ( is_test() ? 'fvox@sandbox.pagseguro.com.br' : $self->email ),
            documents  => [$document]
        };
    }
    else {
        $ret = {
            hash      => $self->sender_hash,
            name      => $self->name,
            phone     => $self->build_phone_object(),
            email     => ( is_test() ? 'fvox@sandbox.pagseguro.com.br' : $self->email ),
            documents => [$document]
        };
    }

    return $ret;
}

sub build_item_object {
    my ($self) = @_;

    my $item = [
        {
            item => {
                id          => 1,
                description => 'Pagamento Voto Legal',
                amount      => $self->get_license_value(),
                quantity    => 1
            }
        }
    ];

    return $item;
}

sub build_shipping_object {
    my ($self) = @_;

    return { address => $self->get_address_data() };
}

sub build_credit_card_object {
    my ( $self, $credit_card_token ) = @_;

    my $address_data = $self->get_address_data();

    my $credit_card = {
        token       => $credit_card_token,
        installment => {
            quantity => 1,
            value    => $self->get_license_value()
        },
        holder => {
            name      => $self->name,
            phone     => $self->build_phone_object(),
            birthDate => $self->candidate->birth_date,
            documents => [
                {
                    document => {
                        type  => 'CPF',
                        value => $self->candidate->cpf
                    }
                }
            ],
            address => $address_data
        },
        billingAddress => $address_data
    };

    return $credit_card;
}

sub get_address_data {
    my ($self) = @_;

    return {
        country    => 'BRA',
        state      => $self->address_state,
        city       => $self->address_city,
        postalCode => $self->address_zipcode,
        street     => $self->address_street,
        district   => $self->address_district,
        number     => $self->address_house_number,
        complement => $self->address_complement,
    };
}

sub build_phone_object {
    my ($self) = @_;

    my $phone = $self->phone;

    $phone =~ s/\D+//g;

    my $area_code = substr( $phone, 0, 2 );
    my $number = substr( $phone, 2 );
    return {
        areaCode => $area_code,
        number   => $number
    };
}

sub update_code {
    my ( $self, $code ) = @_;

    return $self->update( { code => $code } );
}

sub get_license_value {
    my ($self) = @_;

    my $candidate = $self->candidate;

    my $has_political_movement = $candidate->political_movement_id ? 1 : 0;

    my $is_boleto = $self->method eq 'boleto' ? 1 : 0;

    my $has_promotion;
    my $value;

    if ( ( $candidate->political_movement_id && $candidate->political_movement_id =~ /^(1|2|3|4|5|8|9)$/ ) || $candidate->party_id =~ /^(34|26|4|15)$/ ) {
        $has_promotion = 1;
    }

    if ($has_promotion) {

        if ($is_boleto) {

            if ($has_political_movement) {

                if ( $candidate->political_movement_id == 1 ) {
                    $value = '246.50';
                }
                elsif ( $candidate->party_id == 26 ) {
                    $value = '296.00';
                }
                elsif ( $candidate->political_movement_id == 9 ) {
                    $value = '346.50'
                }
                else {
                    $value = '395.00';
                }

            }
            else {

                if ( $candidate->party_id == 26 ) {
                    $value = '296.00';
                }
                elsif( $candidate->party_id == 15 ) {
                    $value = '346.50';
                }
                else {
                    $value = '395.00';
                }

            }

        }
        else {

            if ( $candidate->political_movement_id && $candidate->political_movement_id == 1 ) {
                $value = '247.50';
            }
            elsif ( $candidate->party_id == 26 ) {
                $value = '297.00';
            }
            else {
                $value = '396.00';
            }

        }

    }
    else {
        $value = $is_boleto ? '494.00' : '495.00';
    }

    return $value;
}

sub get_license_value_in_cents {
    my ($self) = @_;

    my $candidate = $self->candidate;

    my $has_political_movement = $candidate->political_movement_id ? 1 : 0;

    my $is_boleto = $self->method eq 'boleto' ? 1 : 0;

    my $has_promotion;
    my $value;

    if ( ( $candidate->political_movement_id && $candidate->political_movement_id =~ /^(1|2|3|4|5|8|9)$/ ) || $candidate->party_id =~ /^(34|26|4|15)$/ ) {
        $has_promotion = 1;
    }

    if ($has_promotion) {

        if ($has_political_movement) {

            if ( $candidate->political_movement_id == 1 ) {
                $value = 14850;
            }
            elsif ( $candidate->party_id == 26 ) {
                $value = 17820;
            }
            elsif ( $candidate->political_movement_id == 9 ) {
                $value = 20800;
            }
            else {
                $value = 23760;
            }

        }
        else {

            if ( $candidate->party_id == 26 ) {
                $value = 17820;
            }
            elsif( $candidate->party_id == 15 ) {
                $value = 20800;
            }
            elsif( $candidate->party_id == 4 && $candidate->address_state eq 'MT' ) {
                $value = 14850;
            }
            else {
                $value = 23760;
            }

        }

    }
    else {
        $value = 29700;
    }

    return $value;
}

sub get_most_recent_log {
    my ($self) = @_;

    return $self->payment_logs->search( undef, { max => 'created_at' } )->next;
}

sub get_human_like_method {
    my ($self) = @_;

    my $ret;

    if ( $self->method eq 'creditCard' ) {
        $ret = 'cartão de crédito';
    }
    elsif ( $self->method eq 'deposit' ) {
        $ret = 'depósito';
    }
    else {
        $ret = 'boleto';
    }
    return $ret;
}

sub get_pagseguro_data {
    my ($self) = @_;

    if ( is_test() ) {
        $self->update(
            {
               gross_amount => 10,
               fee_amount   => 3,
               net_amount   => 7
            }
        );

        return {
            grossAmount => 10,
            feeAmount   => 3,
            netAmount   => 7
        };
    }

    my $merchant_id  = $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID};
    my $merchant_key = $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY};

    my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $merchant_id,
        merchant_key => $merchant_key,
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX},
    );

    my $payment_data = $pagseguro->transaction_data( $self->code );

    if ( ref $payment_data ne 'HASH' ) {
        return 0;
    }
    else {
        $self->update(
            {
               gross_amount => $payment_data->{grossAmount},
               fee_amount   => $payment_data->{feeAmount},
               net_amount   => $payment_data->{netAmount}
            }
        );

        return $payment_data;
    }
}

sub get_iugu_data {
    my ($self) = @_;

	my $gateway = WebService::IuguForReal->instance();

    if ( is_test() ) {
        $self->update(
            {
               gross_amount => 10,
               fee_amount   => 3,
               net_amount   => 7
            }
        );

        return {
            grossAmount => 10,
            feeAmount   => 3,
            netAmount   => 7
        };
    }

    if ( !$self->code ) {
        return {
			gross_amount => undef,
			fee_amount   => undef,
			net_amount   => undef,
			secure_id    => undef
        }
    }

    my %opts = (
        gateway_id           => $self->code,
        is_votolegal_payment => 1,
    );

    my $payment_data = $gateway->get_invoice( %opts );

    if ( ref $payment_data ne 'HASH' ) {
        return 0;
    }
    else {
        $self->update(
            {
               gross_amount => $payment_data->{total_cents} / 100,
               fee_amount   => $payment_data->{taxes_paid_cents} / 100,
               net_amount   => ( $payment_data->{total_cents} - $payment_data->{taxes_paid_cents} ) / 100,
               secure_id    => $payment_data->{gateway_id}
            }
        );

        return $payment_data;
    }
}

sub has_amount_data {
    my ($self) = @_;

    # Verifico se há algum dado de valor.
    # Caso tenha, não é necessário buscar no
    # Pagseguro.

    return $self->gross_amount ? 1 : 0;
}

sub create_log_success {
    my ($self) = @_;

    return $self->payment_logs->create( { status => 'captured' } );
}

sub create_log_refused {
	my ($self) = @_;

	return $self->payment_logs->create( { status => 'refused' } );
}

__PACKAGE__->meta->make_immutable;
1;
