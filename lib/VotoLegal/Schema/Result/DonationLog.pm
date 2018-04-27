use utf8;
package VotoLegal::Schema::Result::DonationLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::DonationLog

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

=head1 TABLE: C<donation_log>

=cut

__PACKAGE__->table("donation_log");

=head1 ACCESSORS

=head2 donation_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=head2 status

  data_type: 'text'
  is_nullable: 0

=head2 status_updated_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "donation_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 32 },
  "status",
  { data_type => "text", is_nullable => 0 },
  "status_updated_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 RELATIONS

=head2 donation

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Donation>

=cut

__PACKAGE__->belongs_to(
  "donation",
  "VotoLegal::Schema::Result::Donation",
  { id => "donation_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-04-27 12:03:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:htJ+5ARAD22SORZvGXuvVw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
