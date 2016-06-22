use utf8;
package VotoLegal::Schema::Result::IssuePriority;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::IssuePriority

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

=head1 TABLE: C<issue_priority>

=cut

__PACKAGE__->table("issue_priority");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'issue_priority_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "issue_priority_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 candidate_issue_priorities

Type: has_many

Related object: L<VotoLegal::Schema::Result::CandidateIssuePriority>

=cut

__PACKAGE__->has_many(
  "candidate_issue_priorities",
  "VotoLegal::Schema::Result::CandidateIssuePriority",
  { "foreign.issue_priority_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 candidates

Type: many_to_many

Composing rels: L</candidate_issue_priorities> -> candidate

=cut

__PACKAGE__->many_to_many("candidates", "candidate_issue_priorities", "candidate");


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-06-22 11:40:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E+wiRgK4Sm+yGEavOWyUJg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
