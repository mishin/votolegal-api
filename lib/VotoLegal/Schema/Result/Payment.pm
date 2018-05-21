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
  { data_type => "text", is_nullable => 0 },
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

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hEyowmVu9X+nL8NB1Gimrg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;
use JSON::MaybeXS;
use XML::Hash::XS qw/ hash2xml /;

sub send_pagseguro_transaction {
    my ($self, $credit_card_token, $log) = @_;

    my $xs = XML::Hash::XS->new(utf8 => 0, encoding => 'utf-8');

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
    my $callback_url = $self->build_callback_url();
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

    $payment_args = $xs->hash2xml($payment_args, root => 'payment');

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

sub build_callback_url {
    my ($self) = @_;

    my $candidate    = $self->candidate;
    my $candidate_id = $self->candidate_id;

    my $callback_url = $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL};
    $callback_url   .= "/" unless $callback_url =~ m{\/$};
    $callback_url   .= "api/candidate/$candidate_id/payment/callback";

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

    if ($ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX}) {
        $ret = {
            senderHash => $self->sender_hash,
            name       => $self->name,
            phone      => $self->build_phone_object(),
            email      => (is_test() ? 'fvox@sandbox.pagseguro.com.br' : $self->email),
            documents  => [ $document ]
        }
    }
    else {
        $ret = {
            hash       => $self->sender_hash,
            name       => $self->name,
            phone      => $self->build_phone_object(),
            email      => (is_test() ? 'fvox@sandbox.pagseguro.com.br' : $self->email),
            documents  => [ $document ]
        }
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
                amount      => $self->get_value(),
                quantity    => 1
            }
        }
    ];

    return $item;
}

sub build_shipping_object {
    my ($self) = @_;

    return {
        address => $self->get_address_data()
    }
}

sub build_credit_card_object {
    my ($self, $credit_card_token) = @_;

    my $address_data = $self->get_address_data();

    my $credit_card = {
        token       => $credit_card_token,
        installment => {
            quantity => 1,
            value    => $self->get_value()
        },
        holder      => {
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
            address  => $address_data
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
    }
}

sub build_phone_object {
    my ($self) = @_;

    my $phone = $self->phone;

    $phone =~ s/\D+//g;

    my $area_code = substr($phone, 0, 2);
    my $number    = substr($phone, 2);
    return {
        areaCode => $area_code,
        number   => $number
    }
}

sub update_code {
    my ($self, $code) = @_;

    return $self->update( { code => $code } );
}

sub get_value {
    my ($self) = @_;

    my $candidate = $self->candidate;

    my $has_political_movement = $candidate->political_movement_id ? 1 : 0;

    my $is_boleto = $self->method eq 'boleto' ? 1 : 0;

    my $has_promotion;
    my $value;

    if ( $candidate->political_movement_id =~ /^(1|2|3|4|5)$/ || $candidate->party_id =~ /^(34|26)$/ ) {
        $has_promotion = 1;
    }

    if ($has_promotion) {

        if ( $is_boleto ) {

            if ($has_political_movement) {

                if ( $candidate->political_movement_id == 1 ) {
                    $value = '246.50';
                }
                elsif ( $candidate->party_id == 26 ) {
                    $value = '296.00';
                }
                else {
                    $value = '395.00';
                }

            }
            else {

                if ( $candidate->party_id == 26 ) {
                    $value = '296.00';
                }
                else {
                    $value = '395.00'
                }

            }

        }
        else {

            if ( $candidate->political_movement_id == 1 ) {
                $value = '247.50'
            }
            elsif ( $candidate->party_id == 26 ) {
                $value = '297.00'
            }
            else {
                $value = '396.00'
            }

        }

    }
    else {
        $value = $is_boleto ? '494.00' : '495.00';
    }

    return $value;
}

sub get_most_recent_log {
    my ($self) = @_;

    return $self->payment_logs->search( undef, { max => 'created_at' } )->next;
}

sub get_human_like_method {
    my ($self) = @_;

    return $self->method eq 'creditCard' ? 'cartão de crédito' : 'boleto';
}

sub get_pagseguro_data {
    my ($self) = @_;

    my $merchant_id  = $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID};
    my $merchant_key = $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY};

    my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $merchant_id,
        merchant_key => $merchant_key,
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX},
    );

    my $payment_data = $pagseguro->transaction_data($self->code);

    if ( ref $payment_data ne 'HASH' ) {
        return 0;
    }
    else {
        return $payment_data;
    }
}

__PACKAGE__->meta->make_immutable;
1;
