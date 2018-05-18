use utf8;
package VotoLegal::Schema::Result::DonationFpDetail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::DonationFpDetail

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

=head1 TABLE: C<donation_fp_detail>

=cut

__PACKAGE__->table("donation_fp_detail");

=head1 ACCESSORS

=head2 donation_fp_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 donation_fp_key_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 donation_fp_value_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "donation_fp_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "donation_fp_key_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "donation_fp_value_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 RELATIONS

=head2 donation_fp

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DonationFp>

=cut

__PACKAGE__->belongs_to(
  "donation_fp",
  "VotoLegal::Schema::Result::DonationFp",
  { id => "donation_fp_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 donation_fp_key

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DonationFpKey>

=cut

__PACKAGE__->belongs_to(
  "donation_fp_key",
  "VotoLegal::Schema::Result::DonationFpKey",
  { id => "donation_fp_key_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 donation_fp_value

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DonationFpValue>

=cut

__PACKAGE__->belongs_to(
  "donation_fp_value",
  "VotoLegal::Schema::Result::DonationFpValue",
  { id => "donation_fp_value_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-18 13:21:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8ot1sak2uYun8J4j7i5yHw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
