#<<<
use utf8;
package VotoLegal::Schema::Result::CandidateServiceDonationInscription;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("candidate_service_donation_inscription");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "candidate_service_donation_inscription_id_seq",
  },
  "validation_token",
  { data_type => "text", is_nullable => 0 },
  "candidate_service_donation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "candidate_service_donor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "candidate_refused_at",
  { data_type => "timestamp", is_nullable => 1 },
  "candidate_accepted_at",
  { data_type => "timestamp", is_nullable => 1 },
  "donor_accepted_at",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->belongs_to(
  "candidate_service_donation",
  "VotoLegal::Schema::Result::CandidateServiceDonation",
  { id => "candidate_service_donation_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "candidate_service_donor",
  "VotoLegal::Schema::Result::CandidateServiceDonor",
  { id => "candidate_service_donor_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-07-02 17:42:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yogyht7kk9GAAlXeMxt8Fg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
