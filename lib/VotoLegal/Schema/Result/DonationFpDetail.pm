#<<<
use utf8;
package VotoLegal::Schema::Result::DonationFpDetail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("donation_fp_detail");
__PACKAGE__->add_columns(
  "donation_fp_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "donation_fp_key_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "donation_fp_value_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->belongs_to(
  "donation_fp",
  "VotoLegal::Schema::Result::DonationFp",
  { id => "donation_fp_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "donation_fp_key",
  "VotoLegal::Schema::Result::DonationFpKey",
  { id => "donation_fp_key_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "donation_fp_value",
  "VotoLegal::Schema::Result::DonationFpValue",
  { id => "donation_fp_value_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fHi6YbhV3g8gGr+oCdKNnQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
