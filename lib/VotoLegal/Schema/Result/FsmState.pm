use utf8;
package VotoLegal::Schema::Result::FsmState;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::FsmState

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

=head1 TABLE: C<fsm_state>

=cut

__PACKAGE__->table("fsm_state");

=head1 ACCESSORS

=head2 fsm_class

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 auto_continue

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "fsm_class",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "auto_continue",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</fsm_class>

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("fsm_class", "name");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-04-28 00:01:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jChhTGqfYXKCv1W7vqfyxg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
