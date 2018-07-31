#<<<
use utf8;
package VotoLegal::Schema::Result::ContractSignature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("contract_signature");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "contract_signature_id_seq",
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ip_address",
  { data_type => "text", is_nullable => 0 },
  "signed_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "is_pre_campaign",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "user",
  "VotoLegal::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-07-31 14:59:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M1b5KtGYif3Pn4/xlp9vRw

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
