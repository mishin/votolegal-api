use utf8;
package VotoLegal::Schema::Result::VotolegalDonation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::VotolegalDonation

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

=head1 TABLE: C<votolegal_donation>

=cut

__PACKAGE__->table("votolegal_donation");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 candidate_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 state

  data_type: 'text'
  default_value: 'created'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 captured_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 refunded_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 compensated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 transferred_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 registered_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 decred_transaction_hash

  data_type: 'text'
  is_nullable: 1

=head2 is_boleto

  data_type: 'boolean'
  is_nullable: 0

=head2 is_pre_campaign

  data_type: 'boolean'
  is_nullable: 0

=head2 payment_info

  data_type: 'json'
  is_nullable: 1

=head2 gateway_tid

  data_type: 'text'
  is_nullable: 1

=head2 gateway_data

  data_type: 'json'
  is_nullable: 1

=head2 callback_id

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 payment_gateway_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 certiface_token_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 device_authorization_token_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "state",
  {
    data_type     => "text",
    default_value => "created",
    is_nullable   => 0,
    original      => { data_type => "varchar" },
  },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "captured_at",
  { data_type => "timestamp", is_nullable => 1 },
  "refunded_at",
  { data_type => "timestamp", is_nullable => 1 },
  "compensated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "transferred_at",
  { data_type => "timestamp", is_nullable => 1 },
  "registered_at",
  { data_type => "timestamp", is_nullable => 1 },
  "decred_transaction_hash",
  { data_type => "text", is_nullable => 1 },
  "is_boleto",
  { data_type => "boolean", is_nullable => 0 },
  "is_pre_campaign",
  { data_type => "boolean", is_nullable => 0 },
  "payment_info",
  { data_type => "json", is_nullable => 1 },
  "gateway_tid",
  { data_type => "text", is_nullable => 1 },
  "gateway_data",
  { data_type => "json", is_nullable => 1 },
  "callback_id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "payment_gateway_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "certiface_token_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "device_authorization_token_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 candidate

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 certiface_token

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::CertifaceToken>

=cut

__PACKAGE__->belongs_to(
  "certiface_token",
  "VotoLegal::Schema::Result::CertifaceToken",
  { id => "certiface_token_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 device_authorization_token

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DeviceAuthorizationToken>

=cut

__PACKAGE__->belongs_to(
  "device_authorization_token",
  "VotoLegal::Schema::Result::DeviceAuthorizationToken",
  { id => "device_authorization_token_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 payment_gateway

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::PaymentGateway>

=cut

__PACKAGE__->belongs_to(
  "payment_gateway",
  "VotoLegal::Schema::Result::PaymentGateway",
  { id => "payment_gateway_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 votolegal_donation_immutable

Type: might_have

Related object: L<VotoLegal::Schema::Result::VotolegalDonationImmutable>

=cut

__PACKAGE__->might_have(
  "votolegal_donation_immutable",
  "VotoLegal::Schema::Result::VotolegalDonationImmutable",
  { "foreign.votolegal_donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-03 10:45:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vXjotrMUTFZ/wvPIATA4Vw

sub resultset { shift->result_source->resultset }

sub as_row {
    my ($self) = @_;

    my $donation = $self->resultset('VotolegalDonation')->search(
        {
            id => $self->id
        },
        {
            prefetch => 'votolegal_donation_immutable'
        }
    )->next;

    my $immu = $donation->votolegal_donation_immutable;
    my $ret  = {
        ( map { $_ => $donation->$_ } qw/id state/ ),
        donor => {

            name => $immu->donor_name,
            cpf  => $immu->get_column('donor_cpf'),
        },
        amount => $immu->amount,

    };

    return $ret;

}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
