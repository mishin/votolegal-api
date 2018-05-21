use utf8;

package VotoLegal::Schema::Result::PaymentDiscount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::PaymentDiscount

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

=head1 TABLE: C<payment_discount>

=cut

__PACKAGE__->table("payment_discount");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'payment_discount_id_seq'

=head2 party_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 political_movement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 discount_type

  data_type: 'text'
  is_nullable: 0

=head2 value

  data_type: 'numeric'
  is_nullable: 0
  size: [2,2]

=head2 valid_from

  data_type: 'timestamp'
  is_nullable: 0

=head2 valid_until

  data_type: 'timestamp'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "payment_discount_id_seq",
    },
    "party_id",
    { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
    "political_movement_id",
    { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
    "discount_type",
    { data_type => "text", is_nullable => 0 },
    "value",
    { data_type => "numeric", is_nullable => 0, size => [ 2, 2 ] },
    "valid_from",
    { data_type => "timestamp", is_nullable => 0 },
    "valid_until",
    { data_type => "timestamp", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 party

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Party>

=cut

__PACKAGE__->belongs_to(
    "party",
    "VotoLegal::Schema::Result::Party",
    { id => "party_id" },
    {
        is_deferrable => 0,
        join_type     => "LEFT",
        on_delete     => "NO ACTION",
        on_update     => "NO ACTION",
    },
);

=head2 political_movement

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::PoliticalMovement>

=cut

__PACKAGE__->belongs_to(
    "political_movement",
    "VotoLegal::Schema::Result::PoliticalMovement",
    { id => "political_movement_id" },
    {
        is_deferrable => 0,
        join_type     => "LEFT",
        on_delete     => "NO ACTION",
        on_update     => "NO ACTION",
    },
);

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-08 16:02:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GnVVqllgCjwtl1HG2xRgPA

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
