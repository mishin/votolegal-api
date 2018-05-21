#<<<
use utf8;
package VotoLegal::Schema::Result::EmaildbConfig;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("emaildb_config");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "emaildb_config_id_seq",
  },
  "from",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "template_resolver_class",
  { data_type => "varchar", is_nullable => 0, size => 60 },
  "template_resolver_config",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "email_transporter_class",
  { data_type => "varchar", is_nullable => 0, size => 60 },
  "email_transporter_config",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "delete_after",
  { data_type => "interval", default_value => "7 days", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "emaildb_queues",
  "VotoLegal::Schema::Result::EmaildbQueue",
  { "foreign.config_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w4hDg9RN8fFgomM7XkeYhw

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
