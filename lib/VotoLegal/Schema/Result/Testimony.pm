#<<<
use utf8;
package VotoLegal::Schema::Result::Testimony;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("testimony");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "testimony_id_seq",
  },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "reviewer_picture",
  { data_type => "text", is_nullable => 1 },
  "reviewer_name",
  { data_type => "text", is_nullable => 0 },
  "reviewer_text",
  { data_type => "text", is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-07-12 11:41:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uXlPXc2Yoh18Wa6z16ZjQw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
with 'VotoLegal::Role::Verification';
with 'VotoLegal::Role::Verification::TransactionalActions::DBIC';

sub verifiers_specs {
    my $self = shift;

    return {
        update => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                reviewer_name => {
                    required => 0,
                    type     => 'Str'
                },
                reviewer_text => {
                    requried => 0,
                    type     => 'Str'
                },
                reviewer_picture => {
                    required => 0,
                    type     => 'Str'
                },
                active => {
                    required => 0,
                    type     => 'Bool'
                }
            }
        )
    }
}

sub action_specs {
    my $self = shift;

    return {
        update => sub {
            my $r = shift;

			my %values = $r->valid_values;
			not defined $values{$_} and delete $values{$_} for keys %values;

            return $self->update(\%values);
        }
    }
}

__PACKAGE__->meta->make_immutable;
1;
