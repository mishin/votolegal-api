use utf8;
package VotoLegal::Schema::Result::DonationFp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::DonationFp

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

=head1 TABLE: C<donation_fp>

=cut

__PACKAGE__->table("donation_fp");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'donation_fp_id_seq'

=head2 fp_hash

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 user_agent_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 ms

  data_type: 'integer'
  is_nullable: 1

=head2 canvas_result

  data_type: 'bigint'
  is_nullable: 1

=head2 webgl_result

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "donation_fp_id_seq",
  },
  "fp_hash",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "user_agent_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "ms",
  { data_type => "integer", is_nullable => 1 },
  "canvas_result",
  { data_type => "bigint", is_nullable => 1 },
  "webgl_result",
  { data_type => "bigint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 donation_fp_details

Type: has_many

Related object: L<VotoLegal::Schema::Result::DonationFpDetail>

=cut

__PACKAGE__->has_many(
  "donation_fp_details",
  "VotoLegal::Schema::Result::DonationFpDetail",
  { "foreign.donation_fp_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_agent

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DeviceAuthorizationUa>

=cut

__PACKAGE__->belongs_to(
  "user_agent",
  "VotoLegal::Schema::Result::DeviceAuthorizationUa",
  { id => "user_agent_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-18 19:27:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tr3rc+vtUodpz3LcOkSFTQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
