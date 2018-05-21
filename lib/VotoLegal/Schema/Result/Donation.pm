#<<<
use utf8;
package VotoLegal::Schema::Result::Donation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("donation");
__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "cpf",
  { data_type => "text", is_nullable => 0 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "amount",
  { data_type => "integer", is_nullable => 0 },
  "status",
  { data_type => "text", is_nullable => 0 },
  "birthdate",
  { data_type => "date", is_nullable => 1 },
  "transaction_hash",
  { data_type => "text", is_nullable => 1 },
  "ip_address",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "address_state",
  { data_type => "text", is_nullable => 1 },
  "address_city",
  { data_type => "text", is_nullable => 1 },
  "address_zipcode",
  { data_type => "text", is_nullable => 1 },
  "address_street",
  { data_type => "text", is_nullable => 1 },
  "address_complement",
  { data_type => "text", is_nullable => 1 },
  "address_house_number",
  { data_type => "integer", is_nullable => 1 },
  "billing_address_street",
  { data_type => "text", is_nullable => 1 },
  "billing_address_house_number",
  { data_type => "integer", is_nullable => 1 },
  "billing_address_district",
  { data_type => "text", is_nullable => 1 },
  "billing_address_zipcode",
  { data_type => "text", is_nullable => 1 },
  "billing_address_city",
  { data_type => "text", is_nullable => 1 },
  "billing_address_state",
  { data_type => "text", is_nullable => 1 },
  "billing_address_complement",
  { data_type => "text", default_value => "", is_nullable => 1 },
  "address_district",
  { data_type => "text", is_nullable => 1 },
  "captured_at",
  { data_type => "timestamp", is_nullable => 1 },
  "payment_gateway_code",
  { data_type => "text", is_nullable => 1 },
  "species",
  {
    data_type     => "text",
    default_value => "Cart\xE3o de cr\xE9dito",
    is_nullable   => 1,
  },
  "by_votolegal",
  { data_type => "boolean", is_nullable => 0 },
  "donation_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "payment_gateway_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "certiface_token_id",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "donation_type",
  "VotoLegal::Schema::Result::DonationType",
  { id => "donation_type_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "payment_gateway",
  "VotoLegal::Schema::Result::PaymentGateway",
  { id => "payment_gateway_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->has_many(
  "project_votes",
  "VotoLegal::Schema::Result::ProjectVote",
  { "foreign.donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TqQVnkk4pJk8LH2KkDMS5Q

use common::sense;
use Digest::MD5 qw(md5_hex);
use Data::Section::Simple qw(get_data_section);

use VotoLegal::Utils;
use VotoLegal::Payment::Cielo;
use VotoLegal::Payment::PagSeguro;

# Pagseguro.
has sender_hash => (
    is  => "rw",
    isa => "Str",
);

has credit_card_token => (
    is  => "rw",
    isa => "Str",
);

has notification_url => (
    is  => "rw",
    isa => "Str",
);

# Cielo.
has credit_card_name => (
    is  => "rw",
    isa => "Str",
);

has credit_card_validity => (
    is  => "rw",
    isa => "Str",
);

has credit_card_number => (
    is  => "rw",
    isa => "Str",
);

has credit_card_brand => (
    is  => "rw",
    isa => "Str",
);

has credit_card_cvv => (
    is  => "rw",
    isa => "Str",
);

# Iugu
has credit_card_token => (
    is  => "rw",
    isa => "Str"
);

has _driver => (
    is   => "rw",
    does => "VotoLegal::Payment",
);

has _transaction_id => (
    is  => "rw",
    isa => "Str",
);

has logger => ( is => "rw", );

sub tokenize {
    my ($self) = @_;

    if ( $self->payment_gateway_id == 1 ) {

        # Cielo.
        defined $self->credit_card_name     or die "missing 'credit_card_name'.";
        defined $self->credit_card_validity or die "missing 'credit_card_validity'.";
        defined $self->credit_card_number   or die "missing 'credit_card_number'.";
        defined $self->credit_card_brand    or die "missing 'credit_card_brand'.";
        defined $self->credit_card_cvv      or die "missing 'credit_card_cvv'.";

        # Tokenizando o cartão.
        my $card_token = $self->driver->tokenize_credit_card(
            credit_card_data => {
                credit_card => {
                    validity     => $self->credit_card_validity,
                    name_on_card => $self->credit_card_name,
                    brand        => $self->credit_card_brand,
                },
                secret => {
                    number => $self->credit_card_number,
                    cvv    => $self->credit_card_cvv,
                },
            },
            order_data => {
                id     => $self->id,
                amount => $self->amount,
                name   => $self->name,
            }
        );

        $self->update( { status => "tokenized" } );
        return 1;
    }
    elsif ( $self->payment_gateway_id == 2 ) {

        # PagSeguro.
        if ( defined( $self->credit_card_token ) ) {
            return 1;
        }
    }

    return 0;
}

sub authorize {
    my ($self) = @_;

    if ( $self->payment_gateway_id == 1 ) {

        # Cielo.
        if ( $self->driver->do_authorization() ) {
            $self->update( { status => "authorized" } );
            return 1;
        }
    }
    elsif ( $self->payment_gateway_id == 2 ) {

        # PagSeguro.
        return 1;
    }
    elsif ( $self->payment_gateway_id == 3 ) {

        # Iugu
        my $opts = $self->build_iugu_invoice_data();
        if ( $self->driver->do_authorization( %{$opts} ) ) {
            $self->update( { status => "authorized" } );
            return 1;
        }
    }

    return 0;
}

sub capture {
    my ($self) = @_;

    if ( $self->payment_gateway_id == 1 || $self->payment_gateway_id == 3 ) {

        # Cielo ou Iugu.
        if ( $self->driver->do_capture() ) {
            $self->update(
                {
                    payment_gateway_code => $self->driver->payment_gateway_code,
                    status               => "captured",
                    captured_at          => \"now()",
                }
            );
            return 1;
        }
    }
    else {
        # PagSeguro.

        # Tratando alguns dados.
        my $billing_address_complement = $self->billing_address_complement;
        my $phone                      = $self->phone;
        my $phoneDDD                   = substr( $self->phone, 0, 2 );
        my $phoneNumber                = substr( $self->phone, 2 );
        my $amount                     = sprintf( "%.2f", $self->amount / 100 );
        my $birthdate                  = $self->birthdate->strftime("%d/%m/%Y");
        my $zipcode                    = $self->address_zipcode;
        my $cpf                        = $self->cpf;
        $zipcode =~ s/\D//g;
        $cpf =~ s/\D//g;

        my $req = $self->driver->transaction(
            itemQuantity1             => 1,
            itemId1                   => "2",
            paymentMethod             => "creditCard",
            itemDescription1          => "Doação VotoLegal",
            itemAmount1               => $amount,
            reference                 => $self->id,
            senderName                => $self->name,
            senderCPF                 => $cpf,
            senderAreaCode            => $phoneDDD,
            senderPhone               => $phoneNumber,
            senderEmail               => $self->email,
            shippingAddressStreet     => $self->address_street,
            shippingAddressNumber     => $self->address_house_number,
            shippingAddressDistrict   => $self->address_district,
            shippingAddressPostalCode => $zipcode,
            shippingAddressCity       => $self->address_city,
            shippingAddressState      => $self->address_state,
            senderHash                => $self->sender_hash,
            creditCardToken           => $self->credit_card_token,
            installmentQuantity       => 1,
            installmentValue          => $amount,
            creditCardHolderName      => $self->credit_card_name,
            creditCardHolderCPF       => $cpf,
            creditCardHolderBirthDate => $birthdate,
            creditCardHolderAreaCode  => $phoneDDD,
            creditCardHolderPhone     => $phoneNumber,
            billingAddressStreet      => $self->billing_address_street,
            billingAddressNumber      => $self->billing_address_house_number,
            billingAddressDistrict    => $self->billing_address_district,
            billingAddressPostalCode  => $self->billing_address_zipcode,
            billingAddressCity        => $self->billing_address_city,
            billingAddressState       => $self->billing_address_state,
            notificationURL           => $self->notification_url,
            (
                $billing_address_complement
                ? ( billingAddressComplement => $billing_address_complement )
                : ()
            ),
        );

        return 1;
    }

    return 0;
}

sub driver {
    my ($self) = @_;

    if ( ref $self->_driver ) {
        return $self->_driver;
    }

    my $payment_gateway_name = $self->payment_gateway->name;

    my $driverName = "VotoLegal::Payment::" . $payment_gateway_name;

    my $driver = $driverName->new(
        merchant_id  => $self->candidate->merchant_id,
        merchant_key => $self->candidate->merchant_key,
        sandbox      => is_test(),
        logger       => $self->logger,
    );

    $self->_driver($driver);

    return $self->_driver;
}

sub send_email {
    my $self = shift;

    # Capturando o total de pessoas que já doaram (menos eu mesmo).
    my $people_donated = $self->candidate->people_donated - 1;

    # Quando fui o primeiro, a mensagem é uma. Quando outras pessoas já doaram, a mensagem é outra.
    my $total_msg;
    if ( $people_donated > 0 ) {
        $total_msg = "e outras $people_donated pessoas já doaram";
    }
    else {
        $total_msg = "foi a primeira pessoa a doar";
    }

    # Buildando o email.
    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->email,
        from     => 'no-reply@votolegal.org.br',
        subject  => "Doação confirmada",
        template => get_data_section('email.tt'),
        vars     => {
            donation_name => $self->name,
            donation_cpf  => $self->cpf,
            ,
            donation_amount => sprintf( "%.2f", ( $self->amount / 100 ) ),
            donation_date   => $self->captured_at->strftime("%d/%m/%Y"),
            candidate_name  => $self->candidate->name,
            candidate_cnpj  => $self->candidate->cnpj,
            candidate_cpf   => $self->candidate->cpf,
            total_donations => $total_msg,
            transaction_hash => $self->transaction_hash,
        }
    )->build_email();

    # Inserindo na queue.
    return $self->result_source->schema->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
        }
    );
}

sub send_email_canceled {
    my $self = shift;

    # Buildando o email.
    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->email,
        from     => 'no-reply@votolegal.org.br',
        subject  => "Doação não efetuada",
        template => get_data_section('canceled.tt'),
        vars     => {
            donation_name  => $self->name,
            candidate_name => $self->candidate->name,
        }
    )->build_email();

    # Inserindo na queue.
    return $self->result_source->schema->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
        }
    );
}

sub build_iugu_invoice_data {
    my ($self) = @_;

    return {
        token  => $self->credit_card_token,
        amount => $self->amount,
        email  => $self->email,
        payer  => {
            cpf_cnpj => $self->cpf,
            name     => $self->name,
            address  => {
                state    => $self->address_state,
                city     => $self->address_city,
                district => $self->address_district,
                zip_code => $self->address_zipcode,
                street   => $self->address_street,
                number   => $self->address_house_number,
            }
        }
    };
}

__PACKAGE__->meta->make_immutable;

1;

__DATA__

@@ email.tt

<!doctype html>
<html>
   <head><meta charset="UTF-8"></head>
   <body>
      <div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
         <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
            <tbody>
               <tr>
                  <td>
                     <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
                        <tbody>
                           <tr>
                              <td height="50" align="center" style="font-size:11px">
                              </td>
                           </tr>
                           <tr>
                            <td colspan="2"><a href="https://www.votolegal.com.br/" target="_blank"><img src="https://gallery.mailchimp.com/d3a90e0e7418b8c4e14997e44/images/fec4013c-fb33-4220-9a25-f0adfd89f971.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
                           </tr>
                           <tr>
                              <td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
                                 <table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
                                    <tbody>
                                       <tr>
                                          <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                             <p><span><b>Ol&#225;, [% donation_name %]. Sua doa&#231;&#227;o foi confirmada! </b><br>
                                                <br></span>
                                             </p>
                                             <p> <strong> </strong>Sua doa&#231;&#227;o para o candidato [% candidate_name %] foi confirmado com sucesso!</p>
                                             <p>At&#233; o momento voc&#234; [% total_donations %] para o candidato.</p>
                                             <p>Voc&#234; j&#225; pode observar sua doa&#231;&#227;o na Blockchain! Para fazer isso acesse esse <a href="http://etherscan.io/tx/[% transaction_hash %]" target="_blank" style="color:#4ab957">link</a>.</p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px">
                                             <p><strong>Dados da sua doa&#231;&#227;o:</strong> </p>
                                             <p>Nome do doador: [% donation_name %]
                                                <br>
                                                CPF do doador: [% donation_cpf %]
                                                <br>
                                                Data da confirma&#231;&#227;o da doa&#231;&#227;o: [% donation_date %]
                                                <br>
                                                Valor da contribui&#231;&#227;o: [R$ [% donation_amount %]]
                                                <br>
                                                Nome do candidato: [% candidate_name %]
                                                <br>
                                                CPF do candidato: [% candidate_cpf %]
                                             </p>
                                             <p>&#201; obrigat&#243;rio declarar no imposto de renda a doa&#231;&#227;o. Existe uma se&#231;&#227;o espec&#237;fica chamada: Doa&#231;&#245;es para Partidos Pol&#237;ticos, Comit&#234;s Financeiros e Candidatos a Cargos Eletivos. Basta informar o nome e o CNPJ do candidato.</p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td height="30"></td>
                                       </tr>
                                    </tbody>
                                 </table>
                              </td>
                           </tr>
                        </tbody>
                     </table>
                     <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
                        <tbody>
                           <tr>
                              <td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
                              </td>
                           </tr>
                        </tbody>
                     </table>
                  </td>
               </tr>
            </tbody>
         </table>
      </div>
      </div>
      </div></div>
   </body>
</html>


@@ canceled.tt

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!doctype html>
<html>
   <body>
      <div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
         <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
            <tbody>
               <tr>
                  <td>
                     <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
                        <tbody>
                           <tr>
                              <td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
                                 <table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
                                    <tbody>
                                       <tr>
                                          <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                             <p><span><b>Prezado(a) [% donation_name %],</b><br>
                                                <br></span>
                                             </p>
                                             <p>A sua doação não pôde ser realizada!</p>
                                             <p>O PagSeguro possui um sistema anti-fraude que detecta qualquer anormalidade no seu cadastro bloqueando a doação.</p>
                                             <p>Por favor, certifique-se de que não ouve nenhum débito no seu cartão de crédito e realize sua doação para o candidato [% candidate_name %] novamente.</p>
                                             <p>Antes de clicar em doar, confira se todos os seus dados estão corretos.</p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td height="30"></td>
                                       </tr>
                                       <tr>
                                          <td align="center" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px">
                                             </p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td height="30"></td>
                                       </tr>
                                    </tbody>
                                 </table>
                              </td>
                           </tr>
                        </tbody>
                     </table>
                     <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
                        <tbody>
                           <tr>
                              <td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
                              </td>
                           </tr>
                        </tbody>
                     </table>
                  </td>
               </tr>
            </tbody>
         </table>
      </div>
   </body>
</html>
