use utf8;
package VotoLegal::Schema::Result::FsmTransition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::FsmTransition

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

=head1 TABLE: C<fsm_transition>

=cut

__PACKAGE__->table("fsm_transition");

=head1 ACCESSORS

=head2 fsm_class

  data_type: 'text'
  is_nullable: 0

=head2 from_state

  data_type: 'text'
  is_nullable: 0

=head2 transition

  data_type: 'text'
  is_nullable: 0

=head2 to_state

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "fsm_class",
  { data_type => "text", is_nullable => 0 },
  "from_state",
  { data_type => "text", is_nullable => 0 },
  "transition",
  { data_type => "text", is_nullable => 0 },
  "to_state",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</fsm_class>

=item * L</from_state>

=item * L</to_state>

=back

=cut

__PACKAGE__->set_primary_key("fsm_class", "from_state", "to_state");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-04-28 00:01:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SA8jlJFdOAL7nKV2G/MO2Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
