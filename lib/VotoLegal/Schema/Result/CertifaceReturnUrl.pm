#<<<
use utf8;
package VotoLegal::Schema::Result::CertifaceReturnUrl;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("certiface_return_url");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "url",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "candidates",
  "VotoLegal::Schema::Result::Candidate",
  { "foreign.use_certiface_return_url_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "certiface_tokens",
  "VotoLegal::Schema::Result::CertifaceToken",
  { "foreign.certiface_return_url_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:unCi1xrHdrcA3bs5Xnam1w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
