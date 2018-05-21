use utf8;

package VotoLegal::Schema::Result::PaymentHistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::PaymentHistory

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

__PACKAGE__->load_components( "InflateColumn::DateTime", "TimeStamp", "PassphraseColumn" );

=head1 TABLE: C<payment_history>

=cut

__PACKAGE__->table("payment_history");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'payment_history_id_seq'

=head2 code

  data_type: 'text'
  is_nullable: 0

=head2 action

  data_type: 'text'
  is_nullable: 0

=head2 sender_hash

  data_type: 'text'
  is_nullable: 0

=head2 method

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 address_state

  data_type: 'text'
  is_nullable: 0

=head2 address_city

  data_type: 'text'
  is_nullable: 0

=head2 address_zipcode

  data_type: 'text'
  is_nullable: 0

=head2 address_district

  data_type: 'text'
  is_nullable: 0

=head2 address_street

  data_type: 'text'
  is_nullable: 0

=head2 address_house_number

  data_type: 'integer'
  is_nullable: 0

=head2 address_complement

  data_type: 'text'
  is_nullable: 1

=head2 cpf

  data_type: 'text'
  is_nullable: 0

=head2 phone

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "payment_history_id_seq",
    },
    "code",
    { data_type => "text", is_nullable => 0 },
    "action",
    { data_type => "text", is_nullable => 0 },
    "sender_hash",
    { data_type => "text", is_nullable => 0 },
    "method",
    { data_type => "text", is_nullable => 0 },
    "name",
    { data_type => "text", is_nullable => 0 },
    "email",
    { data_type => "text", is_nullable => 0 },
    "address_state",
    { data_type => "text", is_nullable => 0 },
    "address_city",
    { data_type => "text", is_nullable => 0 },
    "address_zipcode",
    { data_type => "text", is_nullable => 0 },
    "address_district",
    { data_type => "text", is_nullable => 0 },
    "address_street",
    { data_type => "text", is_nullable => 0 },
    "address_house_number",
    { data_type => "integer", is_nullable => 0 },
    "address_complement",
    { data_type => "text", is_nullable => 1 },
    "cpf",
    { data_type => "text", is_nullable => 0 },
    "phone",
    { data_type => "text", is_nullable => 0 },
    "created_at",
    {
        data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
        original      => { default_value => \"now()" },
    },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-04-17 16:53:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xK7quYDFeE9LHosR4Yk55Q

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
