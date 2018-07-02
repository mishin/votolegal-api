#<<<
use utf8;
package VotoLegal::Schema::Result::CandidateServiceDonation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("candidate_service_donation");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "candidate_service_donation_id_seq",
  },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "equivalent_amount",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "vacancies",
  { data_type => "integer", is_nullable => 0 },
  "desciption",
  { data_type => "text", is_nullable => 0 },
  "procedure",
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
  "address_number",
  { data_type => "integer", is_nullable => 0 },
  "address_complement",
  { data_type => "text", is_nullable => 1 },
  "execution_at",
  { data_type => "timestamp", is_nullable => 0 },
  "execution_until",
  { data_type => "timestamp", is_nullable => 0 },
  "inscription_limit",
  { data_type => "timestamp", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->has_many(
  "candidate_service_donation_inscriptions",
  "VotoLegal::Schema::Result::CandidateServiceDonationInscription",
  { "foreign.candidate_service_donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-07-02 17:42:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tFw2L8ono3Z9t5lMKe1Qiw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
