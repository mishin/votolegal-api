use utf8;
package VotoLegal::Schema::Result::CandidateCampaignConfig;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::CandidateCampaignConfig

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

=head1 TABLE: C<candidate_campaign_config>

=cut

__PACKAGE__->table("candidate_campaign_config");

=head1 ACCESSORS

=head2 candidate_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 timezone

  data_type: 'text'
  default_value: 'America/Brasilia'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 pre_campaign_start

  data_type: 'date'
  is_nullable: 0

=head2 pre_campaign_end

  data_type: 'date'
  is_nullable: 0

=head2 campaign_start

  data_type: 'date'
  is_nullable: 0

=head2 campaign_end

  data_type: 'date'
  is_nullable: 0

=cut

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-04-29 10:50:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pxvz97kOFNpT9kte3oVNRQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
