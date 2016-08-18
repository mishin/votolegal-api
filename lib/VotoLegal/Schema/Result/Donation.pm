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


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-08-18 12:19:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S7c7LFHfBM+LYHNdUf3LJQ

use Digest::MD5 qw(md5_hex);

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

__PACKAGE__->meta->make_immutable;

1;

