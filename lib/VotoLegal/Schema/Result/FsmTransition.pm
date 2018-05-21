#<<<
use utf8;
package VotoLegal::Schema::Result::FsmTransition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("fsm_transition");
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
__PACKAGE__->set_primary_key("fsm_class", "from_state", "to_state");
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VYy3hhoN4lYvzET9/RA60Q

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
