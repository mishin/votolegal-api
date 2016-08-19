use utf8;
package VotoLegal::Schema::Result::Donation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::Donation

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<donation>

=cut

__PACKAGE__->table("donation");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 candidate_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 cpf

  data_type: 'text'
  is_nullable: 0

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 amount

  data_type: 'integer'
  is_nullable: 0

=head2 status

  data_type: 'text'
  is_nullable: 0

=head2 birthdate

  data_type: 'date'
  is_nullable: 0

=head2 receipt_id

  data_type: 'integer'
  is_nullable: 0

=head2 transaction_hash

  data_type: 'text'
  is_nullable: 1

=head2 ip_address

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 address_state

  data_type: 'text'
  is_nullable: 0

=head2 address_city

  data_type: 'text'
  is_nullable: 0

=head2 address_zipcode

  data_type: 'text'
  is_nullable: 0

=head2 address_street

  data_type: 'text'
  is_nullable: 0

=head2 address_complement

  data_type: 'text'
  is_nullable: 1

=head2 address_house_number

  data_type: 'integer'
  is_nullable: 0

=head2 billing_address_street

  data_type: 'text'
  is_nullable: 0

=head2 billing_address_house_number

  data_type: 'integer'
  is_nullable: 0

=head2 billing_address_district

  data_type: 'text'
  is_nullable: 0

=head2 billing_address_zipcode

  data_type: 'text'
  is_nullable: 0

=head2 billing_address_city

  data_type: 'text'
  is_nullable: 0

=head2 billing_address_state

  data_type: 'text'
  is_nullable: 0

=head2 billing_address_complement

  data_type: 'text'
  is_nullable: 1

=head2 address_district

  data_type: 'text'
  is_nullable: 0

=head2 captured_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 payment_gateway_code

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "cpf",
  { data_type => "text", is_nullable => 0 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "amount",
  { data_type => "integer", is_nullable => 0 },
  "status",
  { data_type => "text", is_nullable => 0 },
  "birthdate",
  { data_type => "date", is_nullable => 0 },
  "receipt_id",
  { data_type => "integer", is_nullable => 0 },
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
  { data_type => "text", is_nullable => 0 },
  "address_city",
  { data_type => "text", is_nullable => 0 },
  "address_zipcode",
  { data_type => "text", is_nullable => 0 },
  "address_street",
  { data_type => "text", is_nullable => 0 },
  "address_complement",
  { data_type => "text", is_nullable => 1 },
  "address_house_number",
  { data_type => "integer", is_nullable => 0 },
  "billing_address_street",
  { data_type => "text", is_nullable => 0 },
  "billing_address_house_number",
  { data_type => "integer", is_nullable => 0 },
  "billing_address_district",
  { data_type => "text", is_nullable => 0 },
  "billing_address_zipcode",
  { data_type => "text", is_nullable => 0 },
  "billing_address_city",
  { data_type => "text", is_nullable => 0 },
  "billing_address_state",
  { data_type => "text", is_nullable => 0 },
  "billing_address_complement",
  { data_type => "text", is_nullable => 1 },
  "address_district",
  { data_type => "text", is_nullable => 0 },
  "captured_at",
  { data_type => "timestamp", is_nullable => 1 },
  "payment_gateway_code",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 candidate

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 project_votes

Type: has_many

Related object: L<VotoLegal::Schema::Result::ProjectVote>

=cut

__PACKAGE__->has_many(
  "project_votes",
  "VotoLegal::Schema::Result::ProjectVote",
  { "foreign.donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-08-19 16:32:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mLk8MuKBG23zdXucQC44ig

use common::sense;
use Digest::MD5 qw(md5_hex);
use Data::Section::Simple qw(get_data_section);

use VotoLegal::Utils;
use VotoLegal::Payment::Cielo;
use VotoLegal::Payment::PagSeguro;

has _driver => (
    is   => "rw",
    does => "VotoLegal::Payment",
);

has credit_card_token => (
    is  => "rw",
    isa => "Str",
);

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

has _transaction_id => (
    is  => "rw",
    isa => "Str",
);

sub tokenize {
    my ($self) = @_;

    defined $self->credit_card_name     or die "missing 'credit_card_name'.";
    defined $self->credit_card_validity or die "missing 'credit_card_validity'.";
    defined $self->credit_card_number   or die "missing 'credit_card_number'.";

    # Alguns gateways de pagamento tokenizam o cartão de crédito no front-end. Desta forma, o token já deve estar
    # definido no atributo 'credit_card_token'.
    if (defined($self->credit_card_token)) {
        $self->driver->setCreditCardToken($self->credit_card_token);

        return 1;
    }
    else {
        # Ok, o token não veio na request.
        my $card_token = $self->driver->tokenize_credit_card(
            credit_card_data => {
                credit_card => {
                    validity     => $self->credit_card_validity,
                    name_on_card => $self->credit_card_name,
                },
                secret => {
                    number => $self->credit_card_number,
                },
            },
        );

        if ($card_token) {
            $self->driver->setCreditCardToken($card_token);
            return 1;
        }
    }

    return 0;
}

sub authorize {
    my ($self) = @_;

    defined $self->driver->getCreditCardToken or die 'credit card not tokenized.';
    defined $self->credit_card_brand          or die "missing 'credit_card_brand'.";

    my $res = $self->driver->do_authorization(
        token     => $self->_card_token,
        remote_id => substr(md5_hex($self->id), 0, 20),
        brand     => $self->credit_card_brand,
        amount    => $self->amount,
    );

    if ($res->{authorized}) {
        $self->_transaction_id($res->{transaction_id});

        $self->update({ status => "authorized" });

        return 1;
    }
    return 0;
}

sub capture {
    my ($self) = @_;

    defined $self->_transaction_id or die 'transaction not authorized';

    my $res = $self->driver->do_capture(
        transaction_id => $self->_transaction_id
    );

    if ($res->{captured}) {
        $self->update({ status => "captured" });
        return 1;
    }

    return 0;
}

sub driver {
    my ($self) = @_;

    if (ref $self->_driver) {
        return $self->_driver;
    }

    my $payment_gateway_id = $self->candidate->payment_gateway_id;

    my $paymentGateway = $self->result_source->schema->resultset('PaymentGateway')->find($payment_gateway_id);
    die "invalid 'payment_gateway_id'" unless $paymentGateway;

    my $driverName = "VotoLegal::Payment::" . $paymentGateway->name;

    my $driver = $driverName->new(
        merchant_id  => $self->candidate->merchant_id,
        merchant_key => $self->candidate->merchant_key,
        sandbox      => is_test() ? 1 : 0,
    );

    if (ref $driver) {
        $self->_driver($driver);
    }

    return $self->_driver;
}

sub send_email {
    my $self = shift;

    # Capturando o total de pessoas que já doaram (menos eu mesmo).
    my $people_donated = $self->candidate->people_donated - 1;

    # Quando fui o primeiro, a mensagem é uma. Quando outras pessoas já doaram, a mensagem é outra.
    my $total_msg;
    if ($people_donated > 0) {
        $total_msg = "e outras $people_donated pessoas já doaram";
    }
    else {
        $total_msg = "foi a primeira pessoa a doar";
    }

    # Buildando o email.
    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->email,
        from     => 'no-reply@votolegal.org.br',
        subject  => "VotoLegal - Doação confirmada",
        template => get_data_section('email.tt'),
        vars     => {
            donation_name    => $self->name,
            donation_cpf     => $self->cpf,,
            donation_amount  => sprintf("%.2f", ($self->amount / 100)),
            donation_date    => $self->captured_at->strftime("%d/%m/%Y"),
            candidate_name   => $self->candidate->name,
            candidate_cnpj   => $self->candidate->cnpj,
            total_donations  => $total_msg,
            transaction_hash => $self->transaction_hash,
        }
    )->build_email();

    # Inserindo na queue.
    return $self->result_source->schema->resultset('EmailQueue')->create({
        body => $email->as_string,
    });
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
                              <td colspan="2"><a href="http://votolegal.org.br/"><img src="https://www.votolegal.org.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
                           </tr>
                           <tr>
                              <td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
                                 <table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
                                    <tbody>
                                       <tr>
                                          <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                             <p><span><b>Olá [% donation_name %], sua doação foi confirmada! </b><br>
                                                <br></span>
                                             </p>
                                             <p> <strong> </strong>Sua doação para o candidato [% candidate_name %] foi confirmado com sucesso. Até o momento você [% total_donations %] para o candidato.</p>
                                             <p>Você já pode observar sua doação na Blockchain! Para fazer isso acesse esse <a href="http://etherscan.io/tx/[% transaction_hash %]" target="_blank" style="color:#4ab957">link</a>.</p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px">
                                             <p><strong>Dados da sua doação:</strong> </p>
                                             <p>Nome do doador: [% donation_name %]
                                                <br>
                                                CPF do doador: [% donation_cpf %]
                                                <br>
                                                Data da confirmação da doação: [% donation_date %]
                                                <br>
                                                Valor da contribuição: [R$ [% donation_amount %]]
                                                <br>
                                                Nome do candidato: [% candidate_name %]
                                                <br>
                                                CNPJ do candidato: [% candidate_cnpj %]    
                                             </p>
                                             <p>É importante ressaltar que o Voto Legal é uma plataforma aberta e baseada em software livre. Os realizadores não se responsabilizam pelas informações fornecidas pelos candidatos, nem pelo comportamento deles durante o período eleitoral, e se eleitos, durante seus respectivos mandatos. O Voto Legal não é uma intermediadora, a doação é realizada diretamente do doador para a conta de campanha do candidato. O Voto Legal não cobra taxas e não tem nenhuma responsabilidade sobre a transação.</p>
                                             <strong>
                                                <p>Dúvidas? Acesse <a href="https://www.votolegal.org.br/faq/" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
                                                Equipe Voto Legal
                                             </strong>
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
                                 <span><strong>Voto Legal</strong>- Eleições limpas e transparentes. </span>
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
