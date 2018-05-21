#<<<
use utf8;
package VotoLegal::Schema::Result::VotolegalDonationImmutable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("votolegal_donation_immutable");
__PACKAGE__->add_columns(
  "votolegal_donation_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "donation_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "integer", is_nullable => 0 },
  "donor_name",
  { data_type => "text", is_nullable => 0 },
  "donor_email",
  { data_type => "text", is_nullable => 0 },
  "donor_cpf",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "donor_phone",
  { data_type => "text", is_nullable => 1 },
  "donor_birthdate",
  { data_type => "date", is_nullable => 0 },
  "address_zipcode",
  { data_type => "text", is_nullable => 1 },
  "address_state",
  { data_type => "text", is_nullable => 1 },
  "address_city",
  { data_type => "text", is_nullable => 1 },
  "address_district",
  { data_type => "text", is_nullable => 1 },
  "address_street",
  { data_type => "text", is_nullable => 1 },
  "address_house_number",
  { data_type => "integer", is_nullable => 1 },
  "address_complement",
  { data_type => "text", is_nullable => 1 },
  "billing_address_zipcode",
  { data_type => "text", is_nullable => 1 },
  "billing_address_street",
  { data_type => "text", is_nullable => 1 },
  "billing_address_house_number",
  { data_type => "integer", is_nullable => 1 },
  "billing_address_district",
  { data_type => "text", is_nullable => 1 },
  "billing_address_city",
  { data_type => "text", is_nullable => 1 },
  "billing_address_state",
  { data_type => "text", is_nullable => 1 },
  "billing_address_complement",
  { data_type => "text", is_nullable => 1 },
  "started_ip_address",
  { data_type => "inet", is_nullable => 0 },
  "git_hash",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("votolegal_donation_id");
__PACKAGE__->belongs_to(
  "donation_type",
  "VotoLegal::Schema::Result::DonationType",
  { id => "donation_type_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "votolegal_donation",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { id => "votolegal_donation_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aBYbglU6DmR4I1qQzFfmkw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
