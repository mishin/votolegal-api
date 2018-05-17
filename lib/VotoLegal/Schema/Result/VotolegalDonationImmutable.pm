use utf8;
package VotoLegal::Schema::Result::VotolegalDonationImmutable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::VotolegalDonationImmutable

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

=head1 TABLE: C<votolegal_donation_immutable>

=cut

__PACKAGE__->table("votolegal_donation_immutable");

=head1 ACCESSORS

=head2 votolegal_donation_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 donation_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount

  data_type: 'integer'
  is_nullable: 0

=head2 donor_name

  data_type: 'text'
  is_nullable: 0

=head2 donor_email

  data_type: 'text'
  is_nullable: 0

=head2 donor_cpf

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 donor_phone

  data_type: 'text'
  is_nullable: 1

=head2 donor_birthdate

  data_type: 'date'
  is_nullable: 0

=head2 address_zipcode

  data_type: 'text'
  is_nullable: 1

=head2 address_state

  data_type: 'text'
  is_nullable: 1

=head2 address_city

  data_type: 'text'
  is_nullable: 1

=head2 address_district

  data_type: 'text'
  is_nullable: 1

=head2 address_street

  data_type: 'text'
  is_nullable: 1

=head2 address_house_number

  data_type: 'integer'
  is_nullable: 1

=head2 address_complement

  data_type: 'text'
  is_nullable: 1

=head2 billing_address_zipcode

  data_type: 'text'
  is_nullable: 1

=head2 billing_address_street

  data_type: 'text'
  is_nullable: 1

=head2 billing_address_house_number

  data_type: 'integer'
  is_nullable: 1

=head2 billing_address_district

  data_type: 'text'
  is_nullable: 1

=head2 billing_address_city

  data_type: 'text'
  is_nullable: 1

=head2 billing_address_state

  data_type: 'text'
  is_nullable: 1

=head2 billing_address_complement

  data_type: 'text'
  is_nullable: 1

=head2 started_ip_address

  data_type: 'inet'
  is_nullable: 0

=cut

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
);

=head1 PRIMARY KEY

=over 4

=item * L</votolegal_donation_id>

=back

=cut

__PACKAGE__->set_primary_key("votolegal_donation_id");

=head1 RELATIONS

=head2 donation_type

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DonationType>

=cut

__PACKAGE__->belongs_to(
  "donation_type",
  "VotoLegal::Schema::Result::DonationType",
  { id => "donation_type_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 votolegal_donation

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::VotolegalDonation>

=cut

__PACKAGE__->belongs_to(
  "votolegal_donation",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { id => "votolegal_donation_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-17 00:02:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2nnzTfORkm3cOJUsE2sN3w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
