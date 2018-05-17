use utf8;
package VotoLegal::Schema::Result::CpfLock;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::CpfLock

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

=head1 TABLE: C<cpf_locks>

=cut

__PACKAGE__->table("cpf_locks");

=head1 ACCESSORS

=head2 cpf

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "cpf",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</cpf>

=back

=cut

__PACKAGE__->set_primary_key("cpf");


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-17 00:02:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NxKbcSwvPYPm6DJgreQvQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
