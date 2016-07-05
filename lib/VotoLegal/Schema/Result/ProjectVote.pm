use utf8;
package VotoLegal::Schema::Result::ProjectVote;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::ProjectVote

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

=head1 TABLE: C<project_vote>

=cut

__PACKAGE__->table("project_vote");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'project_vote_id_seq'

=head2 donation_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=head2 project_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "project_vote_id_seq",
  },
  "donation_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 32 },
  "project_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 donation

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Donation>

=cut

__PACKAGE__->belongs_to(
  "donation",
  "VotoLegal::Schema::Result::Donation",
  { id => "donation_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 project

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Project>

=cut

__PACKAGE__->belongs_to(
  "project",
  "VotoLegal::Schema::Result::Project",
  { id => "project_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-07-05 11:31:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:15dygVjffgAJZLbB3SQh7Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
