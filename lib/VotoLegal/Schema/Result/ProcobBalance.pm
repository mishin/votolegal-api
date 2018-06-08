#<<<
use utf8;
package VotoLegal::Schema::Result::ProcobBalance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("procob_balance");
__PACKAGE__->add_columns(
  "balance",
  { data_type => "text", is_nullable => 0 },
  "updated_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-06-08 13:49:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k8aBqJeakpbm9DUBCdnnLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
