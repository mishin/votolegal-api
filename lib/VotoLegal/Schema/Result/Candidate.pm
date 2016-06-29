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

=head2 reelection

  data_type: 'boolean'
  is_nullable: 0

=head2 office_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 status

  data_type: 'text'
  is_nullable: 0

=head2 username

  data_type: 'text'
  is_nullable: 0

=head2 address_state

  data_type: 'text'
  is_nullable: 0

=head2 address_city

  data_type: 'text'
  is_nullable: 0

=head2 address_zipcode

  data_type: 'text'
  is_nullable: 0

=head2 address_street

  data_type: 'text'
  is_nullable: 0

=head2 address_complement

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 address_house_number

  data_type: 'integer'
  is_nullable: 0

=head2 cnpj

  data_type: 'text'
  is_nullable: 0

=head2 picture

  data_type: 'text'
  is_nullable: 1

=head2 video_url

  data_type: 'text'
  is_nullable: 1

=head2 facebook_url

  data_type: 'text'
  is_nullable: 1

=head2 twitter_url

  data_type: 'text'
  is_nullable: 1

=head2 website_url

  data_type: 'text'
  is_nullable: 1

=head2 summary

  data_type: 'text'
  is_nullable: 1

=head2 biography

  data_type: 'text'
  is_nullable: 1

=head2 cielo_token

  data_type: 'text'
  is_nullable: 1

=head2 instagram_url

  data_type: 'text'
  is_nullable: 1

=head2 raising_goal

  data_type: 'numeric'
  is_nullable: 1
  size: [11,2]

=head2 public_email

  data_type: 'text'
  is_nullable: 1

=head2 spending_spreadsheet

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
  "reelection",
  { data_type => "boolean", is_nullable => 0 },
  "office_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "status",
  { data_type => "text", is_nullable => 0 },
  "username",
  { data_type => "text", is_nullable => 0 },
  "address_state",
  { data_type => "text", is_nullable => 0 },
  "address_city",
  { data_type => "text", is_nullable => 0 },
  "address_zipcode",
  { data_type => "text", is_nullable => 0 },
  "address_street",
  { data_type => "text", is_nullable => 0 },
  "address_complement",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "address_house_number",
  { data_type => "integer", is_nullable => 0 },
  "cnpj",
  { data_type => "text", is_nullable => 0 },
  "picture",
  { data_type => "text", is_nullable => 1 },
  "video_url",
  { data_type => "text", is_nullable => 1 },
  "facebook_url",
  { data_type => "text", is_nullable => 1 },
  "twitter_url",
  { data_type => "text", is_nullable => 1 },
  "website_url",
  { data_type => "text", is_nullable => 1 },
  "summary",
  { data_type => "text", is_nullable => 1 },
  "biography",
  { data_type => "text", is_nullable => 1 },
  "cielo_token",
  { data_type => "text", is_nullable => 1 },
  "instagram_url",
  { data_type => "text", is_nullable => 1 },
  "raising_goal",
  { data_type => "numeric", is_nullable => 1, size => [11, 2] },
  "public_email",
  { data_type => "text", is_nullable => 1 },
  "spending_spreadsheet",
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

=head2 C<candidate_username_key>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("candidate_username_key", ["username"]);

=head1 RELATIONS

=head2 candidate_issue_priorities

Type: has_many

Related object: L<VotoLegal::Schema::Result::CandidateIssuePriority>

=cut

__PACKAGE__->has_many(
  "candidate_issue_priorities",
  "VotoLegal::Schema::Result::CandidateIssuePriority",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 projects

Type: has_many

Related object: L<VotoLegal::Schema::Result::Project>

=cut

__PACKAGE__->has_many(
  "projects",
  "VotoLegal::Schema::Result::Project",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 issue_priorities

Type: many_to_many

Composing rels: L</candidate_issue_priorities> -> issue_priority

=cut

__PACKAGE__->many_to_many(
  "issue_priorities",
  "candidate_issue_priorities",
  "issue_priority",
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-06-29 10:45:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6HaB6iPp6eeVK3EI/fYRgQ

use Data::Verifier;
use Data::Validate::URI qw(is_web_uri);
use Template;
use VotoLegal::Types qw(CPF);
use VotoLegal::Mailer::Template;
use MooseX::Types::CNPJ qw(CNPJ);
use Data::Section::Simple qw(get_data_section);

with 'VotoLegal::Role::Verification';
with 'VotoLegal::Role::Verification::TransactionalActions::DBIC';

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
                    required   => 0,
                    type       => 'Int',
                    post_check => sub {
                        my $r         = shift;
                        my $office_id = $r->get_value('office_id');

                        $self->resultset('Office')->search({ id => $office_id })->count;
                    },
                },
                reelection => {
                    required   => 0,
                    type       => 'Bool',
                    post_check => sub { 1 },
                },
                status => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $roles = $r->get_value('roles');
                        if (!grep $_ eq 'admin', @$roles) {
                            return 0;
                        }

                        my $status = $r->get_value('status');
                        $status =~ m{^(pending|activated|deactivated)$};
                    }
                },
                roles => {
                    required => 1,
                    type     => 'ArrayRef[Str]',
                },
                address_state => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $state = $r->get_value('address_state');
                        $self->resultset('State')->search({ name => $state })->count;
                    },
                },
                address_city => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $city = $r->get_value('address_city');
                        $self->resultset('City')->search({ name => $city })->count;
                    },
                },
                address_zipcode => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $cep = $r->get_value('address_zipcode');
                        return test_cep($cep);
                    },
                },
                address_street => {
                    required   => 0,
                    type       => 'Str',
                },
                address_house_number => {
                    required   => 0,
                    type       => 'Int',
                },
                address_complement => {
                    required   => 0,
                    type       => 'Str',
                },
                cnpj => {
                    required => 0,
                    type     => CNPJ,
                },
                issue_priorities => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $issue_priorities   = $r->get_value("issue_priorities");
                        my @issue_priority_ids = grep { int($_) == $_ } split(m{\s*,\s*}, $issue_priorities);

                        if (@issue_priority_ids > 4) {
                            return 0;
                        }

                        my @issue_priority = map {
                            $self->resultset('IssuePriority')->find($_) or die \["issue_priorities", "invalid issue_priority_id '$_'"]
                        } @issue_priority_ids;

                        $self->set_issue_priorities(@issue_priority);

                        return 1;
                    },
                },
                picture => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub { is_web_uri $_[0]->get_value('picture') },
                },
                video_url => {
                    required => 0,
                    type     => "Str",
                    post_check => sub { is_web_uri $_[0]->get_value('video_url') },
                },
                facebook_url => {
                    required => 0,
                    type     => "Str",
                    post_check => sub {
                        my $r = shift;

                        my $uri = URI->new($r->get_value('facebook_url'));
                        $uri->host =~ m{(www\.)?facebook\.com$};
                    },
                },
                twitter_url => {
                    required => 0,
                    type     => "Str",
                    post_check => sub {
                        my $r = shift;

                        my $uri = URI->new($r->get_value('twitter_url'));
                        $uri->host =~ m{(www\.)?twitter\.com$};
                    }
                },
                website_url => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub { is_web_uri $_[0]->get_value('website_url') },
                },
                summary => {
                    required => 0,
                    type     => "Str",
                },
                biography => {
                    required => 0,
                    type     => "Str",
                },
                cielo_token => {
                    required => 0,
                    type     => "Str",
                },
                instagram_url => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub { is_web_uri $_[0]->get_value('instagram_url') },
                },
                raising_goal => {
                    required => 0,
                    type     => "Num",
                },
                public_email => {
                    required => 0,
                    type     => EmailAddress,
                },
                spending_spreadsheet => {
                    required => 0,
                    type     => "Str",
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

            # Deletando os values que não pertencem a entidade Candidate.
            delete $values{roles};
            delete $values{issue_priorities};

            if (%values) {
                $self = $self->update(\%values);
            }

            return $self;
        },
    };
}

sub send_email_registration {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org',
        subject  => "VotoLegal - Cadastro realizado",
        template => get_data_section('candidate_registration.tt'),
        vars     => { map { $_ => $self->$_} qw(name) },
    )->build_email();

    return $self->resultset('EmailQueue')->create({
        body => $email->as_string,
    });
}

sub send_email_activation {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org',
        subject  => "VotoLegal - Cadastro aprovado",
        template => get_data_section('candidate_activation.tt'),
        vars     => { map { $_ => $self->$_} qw(name) },
    )->build_email();

    return $self->resultset('EmailQueue')->create({
        body => $email->as_string,
    });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

1;

__DATA__

@@ candidate_registration.tt

Olá [% name %]!<br>
Seu cadastro está pendente para aprovação.<br>

@@ candidate_activation.tt

Olá [% name %]!<br>
Seu cadastro foi aprovado com sucesso!<br>

