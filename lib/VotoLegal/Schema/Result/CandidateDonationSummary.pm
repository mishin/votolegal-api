use utf8;
package VotoLegal::Schema::Result::CandidateDonationSummary;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::CandidateDonationSummary

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

=head1 TABLE: C<candidate_donation_summary>

=cut

__PACKAGE__->table("candidate_donation_summary");

=head1 ACCESSORS

=head2 candidate_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount_donation_by_votolegal

  data_type: 'bigint'
  default_value: 0
  is_nullable: 0

=head2 count_donation_by_votolegal

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 amount_donation_beside_votolegal

  data_type: 'bigint'
  default_value: 0
  is_nullable: 0

=head2 count_donation_beside_votolegal

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 amount_refunded

  data_type: 'bigint'
  default_value: 0
  is_nullable: 0

=head2 count_refunded

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount_donation_by_votolegal",
  { data_type => "bigint", default_value => 0, is_nullable => 0 },
  "count_donation_by_votolegal",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "amount_donation_beside_votolegal",
  { data_type => "bigint", default_value => 0, is_nullable => 0 },
  "count_donation_beside_votolegal",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "amount_refunded",
  { data_type => "bigint", default_value => 0, is_nullable => 0 },
  "count_refunded",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</candidate_id>

=back

=cut

__PACKAGE__->set_primary_key("candidate_id");

=head1 RELATIONS

=head2 candidate

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-20 12:17:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HYwqWSMFg88cHUmLuaYmmQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
