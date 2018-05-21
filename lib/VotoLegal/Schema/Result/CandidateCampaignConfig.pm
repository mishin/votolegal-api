#<<<
use utf8;
package VotoLegal::Schema::Result::CandidateCampaignConfig;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("candidate_campaign_config");
__PACKAGE__->add_columns(
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "timezone",
  {
    data_type     => "text",
    default_value => "America/Brasilia",
    is_nullable   => 0,
    original      => { data_type => "varchar" },
  },
  "pre_campaign_start",
  { data_type => "date", is_nullable => 0 },
  "pre_campaign_end",
  { data_type => "date", is_nullable => 0 },
  "campaign_start",
  { data_type => "date", is_nullable => 0 },
  "campaign_end",
  { data_type => "date", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("candidate_id");
__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4pLB9xJmzg6cWcGsmUZong

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
