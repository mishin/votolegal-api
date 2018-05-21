#<<<
use utf8;
package VotoLegal::Schema::Result::DeviceAuthorizationToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("device_authorization_token");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "verified",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "device_authorization_ua_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "device_ip",
  { data_type => "inet", is_nullable => 0 },
  "created_at",
  { data_type => "timestamp with time zone", is_nullable => 0 },
  "can_create_boleto_without_certiface",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "device_authorization_ua",
  "VotoLegal::Schema::Result::DeviceAuthorizationUa",
  { id => "device_authorization_ua_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);
__PACKAGE__->has_many(
  "votolegal_donations",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { "foreign.device_authorization_token_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Mt6IR+1yjX7U1DaXv7e8XQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
