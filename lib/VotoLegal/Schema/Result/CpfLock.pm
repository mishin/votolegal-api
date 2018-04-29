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

=head1 RELATIONS

=head2 votolegal_donation_immutables

Type: has_many

Related object: L<VotoLegal::Schema::Result::VotolegalDonationImmutable>

=cut

__PACKAGE__->has_many(
  "votolegal_donation_immutables",
  "VotoLegal::Schema::Result::VotolegalDonationImmutable",
  { "foreign.donor_cpf" => "self.cpf" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-04-29 10:50:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UbVvFyvkK1pG3EOPVTQoYQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
