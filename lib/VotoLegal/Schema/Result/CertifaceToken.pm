use utf8;
package VotoLegal::Schema::Result::CertifaceToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::CertifaceToken

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

=head1 TABLE: C<certiface_token>

=cut

__PACKAGE__->table("certiface_token");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

=head2 verification_url

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 votolegal_donation_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 1
  size: 16

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 validated

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 fail_reasons

  data_type: 'json'
  is_nullable: 1

=head2 response_updated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 response

  data_type: 'json'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "verification_url",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "votolegal_donation_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "validated",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "fail_reasons",
  { data_type => "json", is_nullable => 1 },
  "response_updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "response",
  { data_type => "json", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 votolegal_donation

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::VotolegalDonation>

=cut

__PACKAGE__->belongs_to(
  "votolegal_donation",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { id => "votolegal_donation_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-17 01:56:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lrDlRz+yLlr5XAG5DLlgLQ

use WebService::Certiface;
use JSON qw/to_json/;
use DateTime::Format::Pg;

sub process_response_and_validate {
    my ($self) = @_;

    return 1 if $self->response;

    my $ws = WebService::Certiface->instance;

    my $response = $ws->get_token_information( $self->id );
    return 0 unless $response;

    my $is_any_valid = grep { $_->{valid} } @{ $response->{resultados} || [] };
    my @fail_reasons = map { $_->{cause} } grep { $_->{valid} == 0 } @{ $response->{resultados} || [] };

    $self->update(
        {
            validated           => $is_any_valid,
            fail_reasons        => to_json( \@fail_reasons ),
            response            => to_json($response),
            response_updated_at => \'now()',
        }
    );

    # nao foi verificado, se tiver expirado, vamos gerar um novo token
    # e o token nao foi utilizado ja as 3 vezes
    if ( !$is_any_valid && scalar @fail_reasons < 3 ) {

        my $x = $self->result_source->schema->resultset('CertifaceToken')->search(
            { id => $self->id },
            {
                'columns' => [
                    {
                        expirado => \[
                            " (now() - (? || ' America/Sao_Paulo')::timestamp with time zone) >= '0'",
                            $response->{dataExpiracao}
                        ]
                    },
                ],
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            }
        )->next;

        return $x->{expirado};
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;
