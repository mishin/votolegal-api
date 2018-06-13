#<<<
use utf8;
package VotoLegal::Schema::Result::ProcobResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("procob_result");
__PACKAGE__->add_columns(
  "votolegal_donation_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "donor_cpf",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "is_dead_person",
  { data_type => "boolean", is_nullable => 0 },
  "response",
  { data_type => "json", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "updated_at",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->belongs_to(
  "votolegal_donation",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { id => "votolegal_donation_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-06-13 10:09:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8+hB30pnnUh/6KeB9r64OQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
