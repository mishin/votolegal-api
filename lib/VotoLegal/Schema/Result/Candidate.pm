use utf8;
package VotoLegal::Schema::Result::Candidate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::Candidate

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

=head1 TABLE: C<candidate>

=cut

__PACKAGE__->table("candidate");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'candidate_id_seq'

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 popular_name

  data_type: 'text'
  is_nullable: 0

=head2 party_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 cpf

  data_type: 'text'
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 raising_goal

  data_type: 'integer'
  is_nullable: 0

=head2 office_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 video_url

  data_type: 'text'
  is_nullable: 1

=head2 link_tse

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "candidate_id_seq",
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "popular_name",
  { data_type => "text", is_nullable => 0 },
  "party_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "cpf",
  { data_type => "text", is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "raising_goal",
  { data_type => "integer", is_nullable => 0 },
  "office_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "video_url",
  { data_type => "text", is_nullable => 1 },
  "link_tse",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<candidate_cpf_key>

=over 4

=item * L</cpf>

=back

=cut

__PACKAGE__->add_unique_constraint("candidate_cpf_key", ["cpf"]);

=head1 RELATIONS

=head2 office

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Office>

=cut

__PACKAGE__->belongs_to(
  "office",
  "VotoLegal::Schema::Result::Office",
  { id => "office_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 party

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Party>

=cut

__PACKAGE__->belongs_to(
  "party",
  "VotoLegal::Schema::Result::Party",
  { id => "party_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "VotoLegal::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-06-16 09:55:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9DYmCvCWsTZQ7wmIUjfSIw

use Data::Verifier;
use VotoLegal::Types qw(CPF);

with 'VotoLegal::Role::Verification';

sub resultset {
    my $self = shift;

    return $self->result_source->schema->resultset(@_);
}

sub verifiers_specs {
    my $self = shift;

    return {
        update => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required => 0,
                    type     => 'Str',
                },
                popular_name => {
                    required => 0,
                    type     => 'Str',
                },
                party_id    => {
                    required   => 0,
                    type       => 'Int',
                    post_check => sub {
                        my $r = shift;

                        $self->result_source->schema->resultset('Party')
                            ->search({ id => $r->get_value('party_id') })
                            ->count;
                    },
                },
                cpf => {
                    required   => 0,
                    type       => CPF,
                    post_check => sub {
                        my $r = shift;

                        $self->resultset($self->result_source->source_name)->search({
                            cpf     => $r->get_value('cpf'),
                            user_id => { '!=' => $self->user_id },
                        })->count and die \["cpf", "already exists"];

                        return 1;
                    },
                },
                office_id => {
                    required   => 1,
                    type       => 'Int',
                    post_check => sub {
                        my $r         = shift;
                        my $office_id = $r->get_value('office_id');

                        $self->resultset('Office')->search({ id => $office_id })->count;
                    },
                },
                link_tse => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        # TODO Validar a url. 
                        1;
                    },
                },
            },
        ),
    };
}

sub action_specs {
    my $self = shift;

    return {
        update => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            if (%values) {
                my $user = $self->update(\%values);

                return $user;
            }
            return ;
        },
    };
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

1;
