use utf8;
package VotoLegal::Schema::Result::DeviceAuthorizationUa;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::DeviceAuthorizationUa

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

=head1 TABLE: C<device_authorization_ua>

=cut

__PACKAGE__->table("device_authorization_ua");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'device_authorization_ua_id_seq'

=head2 user_agent

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "device_authorization_ua_id_seq",
  },
  "user_agent",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 device_authorization_tokens

Type: has_many

Related object: L<VotoLegal::Schema::Result::DeviceAuthorizationToken>

=cut

__PACKAGE__->has_many(
  "device_authorization_tokens",
  "VotoLegal::Schema::Result::DeviceAuthorizationToken",
  { "foreign.device_authorization_ua_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-04-28 00:01:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:boeDddVordT/xAWwGIRBTA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
