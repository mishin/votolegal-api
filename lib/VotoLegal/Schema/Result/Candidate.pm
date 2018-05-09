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
  is_nullable: 1

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

=head2 responsible_name

  data_type: 'text'
  is_nullable: 1

=head2 responsible_email

  data_type: 'text'
  is_nullable: 1

=head2 merchant_id

  data_type: 'text'
  is_nullable: 1

=head2 merchant_key

  data_type: 'text'
  is_nullable: 1

=head2 payment_status

  data_type: 'text'
  default_value: 'unpaid'
  is_nullable: 0

=head2 publish

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 address_district

  data_type: 'text'
  is_nullable: 1

=head2 payment_gateway_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 bank_code

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 bank_agency

  data_type: 'integer'
  is_nullable: 1

=head2 bank_account_number

  data_type: 'integer'
  is_nullable: 1

=head2 bank_account_dv

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 bank_agency_dv

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 crawlable

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 color

  data_type: 'text'
  default_value: 'default'
  is_nullable: 0

=head2 political_movement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 birth_date

  data_type: 'text'
  is_nullable: 0

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
  { data_type => "text", is_nullable => 1 },
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
  "instagram_url",
  { data_type => "text", is_nullable => 1 },
  "raising_goal",
  { data_type => "numeric", is_nullable => 1, size => [11, 2] },
  "public_email",
  { data_type => "text", is_nullable => 1 },
  "spending_spreadsheet",
  { data_type => "text", is_nullable => 1 },
  "responsible_name",
  { data_type => "text", is_nullable => 1 },
  "responsible_email",
  { data_type => "text", is_nullable => 1 },
  "merchant_id",
  { data_type => "text", is_nullable => 1 },
  "merchant_key",
  { data_type => "text", is_nullable => 1 },
  "payment_status",
  { data_type => "text", default_value => "unpaid", is_nullable => 0 },
  "publish",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "address_district",
  { data_type => "text", is_nullable => 1 },
  "payment_gateway_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "bank_code",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "bank_agency",
  { data_type => "integer", is_nullable => 1 },
  "bank_account_number",
  { data_type => "integer", is_nullable => 1 },
  "bank_account_dv",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "bank_agency_dv",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "crawlable",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "color",
  { data_type => "text", default_value => "default", is_nullable => 0 },
  "political_movement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "birth_date",
  { data_type => "text", is_nullable => 0 },
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

=head2 bank_code

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Bank>

=cut

__PACKAGE__->belongs_to(
  "bank_code",
  "VotoLegal::Schema::Result::Bank",
  { id => "bank_code" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 candidate_campaign_config

Type: might_have

Related object: L<VotoLegal::Schema::Result::CandidateCampaignConfig>

=cut

__PACKAGE__->might_have(
  "candidate_campaign_config",
  "VotoLegal::Schema::Result::CandidateCampaignConfig",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 candidate_mandato_aberto_integrations

Type: has_many

Related object: L<VotoLegal::Schema::Result::CandidateMandatoAbertoIntegration>

=cut

__PACKAGE__->has_many(
  "candidate_mandato_aberto_integrations",
  "VotoLegal::Schema::Result::CandidateMandatoAbertoIntegration",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 donations

Type: has_many

Related object: L<VotoLegal::Schema::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "VotoLegal::Schema::Result::Donation",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 expenditures

Type: has_many

Related object: L<VotoLegal::Schema::Result::Expenditure>

=cut

__PACKAGE__->has_many(
  "expenditures",
  "VotoLegal::Schema::Result::Expenditure",
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

=head2 payment_gateway

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::PaymentGateway>

=cut

__PACKAGE__->belongs_to(
  "payment_gateway",
  "VotoLegal::Schema::Result::PaymentGateway",
  { id => "payment_gateway_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 payments

Type: has_many

Related object: L<VotoLegal::Schema::Result::Payment>

=cut

__PACKAGE__->has_many(
  "payments",
  "VotoLegal::Schema::Result::Payment",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 political_movement

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::PoliticalMovement>

=cut

__PACKAGE__->belongs_to(
  "political_movement",
  "VotoLegal::Schema::Result::PoliticalMovement",
  { id => "political_movement_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
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

=head2 votolegal_donations

Type: has_many

Related object: L<VotoLegal::Schema::Result::VotolegalDonation>

=cut

__PACKAGE__->has_many(
  "votolegal_donations",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-07 18:37:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DkFfL9lC+w0+EDfSnCXA5Q

use File::Temp q(:seekable);
use Data::Verifier;
use Data::Validate::URI qw(is_web_uri);
use Template;
use Business::BR::CEP qw(test_cep);
use VotoLegal::Utils;
use VotoLegal::Types qw(EmailAddress CPF);
use VotoLegal::Mailer::Template;
use MooseX::Types::CNPJ qw(CNPJ);
use Data::Section::Simple qw(get_data_section);

with 'VotoLegal::Role::Verification';
with 'VotoLegal::Role::Verification::TransactionalActions::DBIC';

sub address_state_code {
    my $self = shift;

    my $state = $self->resultset('State')->search({ name => $self->address_state })->next;
    if ($state) {
        return $state->code;
    }
    return ;
}

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
                    post_check => sub {
                        my $name = $_[0]->get_value('name');

                        scalar(split(m{ }, $name)) > 1;
                    },
                },
                popular_name => {
                    required => 0,
                    type     => 'Str',
                },
                party_id    => {
                    required   => 0,
                    type       => "Int",
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
                phone => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $r = shift;
                        my $phone = $r->get_value('phone');
                        return 1 if $phone eq '_SET_NULL_';

                        $r->get_value('phone') =~ m{^\d{10,11}$};
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
                        $self->resultset('State')->search({ code => $state })->count;
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
                    type       => 'Str',
                    type_check => sub {
                        my $address_house_number = $_[0]->get_value('address_house_number');
                        $address_house_number =~ m{^\d+$};
                    },
                },
                address_complement => {
                    required   => 0,
                    type       => 'Str',
                },
                address_district => {
                    type     => "Str",
                    required => 0,
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
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $video_url = $_[0]->get_value('video_url');
                        return 1 if $video_url eq "_SET_NULL_";
                        is_web_uri $video_url
                    },
                },
                facebook_url => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $facebook_url = $_[0]->get_value('facebook_url');
                        return 1 if $facebook_url eq "_SET_NULL_";
                        is_web_uri $facebook_url;
                    },
                },
                twitter_url => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $twitter_url = $_[0]->get_value('twitter_url');
                        return 1 if $twitter_url eq "_SET_NULL_";
                        is_web_uri $twitter_url;
                    },
                },
                website_url => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $website_url = $_[0]->get_value('website_url');
                        return 1 if $website_url eq "_SET_NULL_";
                        is_web_uri $website_url;
                    },
                },
                summary => {
                    required => 0,
                    type     => "Str",
                },
                biography => {
                    required => 0,
                    type     => "Str",
                },
                instagram_url => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $instagram_url = $_[0]->get_value('instagram_url');
                        return 1 if $instagram_url eq "_SET_NULL_";

                        is_web_uri $instagram_url;
                    },
                },
                raising_goal => {
                    required => 0,
                    type     => "Num",
                },
                public_email => {
                    required => 0,
                    type     => "Str",
                },
                spending_spreadsheet => {
                    required => 0,
                    type     => "Str",
                },
                responsible_name => {
                    required => 0,
                    type     => "Str",
                },
                responsible_email => {
                    required => 0,
                    type     => "Str",
                },
                merchant_id => {
                    required => 0,
                    type     => "Str",
                },
                merchant_key => {
                    required => 0,
                    type     => "Str",
                },
                payment_gateway_id => {
                    required   => 0,
                    type       => "Int",
                    post_check => sub {
                        my $r = shift;

                        my $payment_gateway_id = $r->get_value('payment_gateway_id');
                        $self->resultset('PaymentGateway')->find($payment_gateway_id);
                    },
                },
                bank_code => {
                    required   => 0,
                    type       => "Int",
                    post_check => sub {
                        my $r = shift;

                        my $bank_code = $r->get_value('bank_code');
                        $self->resultset('Bank')->find($bank_code);
                    },
                },
                bank_agency => {
                    required => 0,
                    type     => "Str",
                },
                bank_agency_dv => {
                    required => 0,
                    type     => "Str",
                },
                bank_account_number => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $bank_account_number = $_[0]->get_value('bank_account_number');
                        return 1 if $bank_account_number eq "_SET_NULL_";

                        $bank_account_number =~ m{^\d+$};
                    },
                },
                bank_account_dv => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $bank_account_dv = $_[0]->get_value('bank_account_dv');
                        return 1 if $bank_account_dv eq "_SET_NULL_";

                        $bank_account_dv =~ m{^([a-zA-Z0-9]+)$};
                    }
                },
                crawlable => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $crawlable = $_[0]->get_value('crawlable');
                        $crawlable eq "true" || $crawlable eq "false";
                    },
                },
                color => {
                    required => 0,
                    type     => "Str"
                },
                political_movement_id => {
                    required   => 0,
                    type       => "Int",
                    post_check => sub {
                        my $political_movement_id = $_[0]->get_value('political_movement_id');

                        my $political_movement = $self->result_source->schema->resultset('PoliticalMovement')->search( { id => $political_movement_id } )->next;

                        die \['political_movement_id', 'could not find political movement with that id'] unless $political_movement;
                    }
                }
            },
        ),

        publish => Data::Verifier->new(
            filters => [],
            profile => {},
        ),

        unpublish => Data::Verifier->new(
            filters => [],
            profile => {},
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

            for (keys %values) {
                if ($values{$_} eq "_SET_NULL_") {
                    $values{$_} = undef;
                }
            }

            # Deletando os values que não pertencem a entidade Candidate.
            delete $values{roles};
            delete $values{issue_priorities};

            if (%values) {
                $self = $self->update(\%values);
            }

            return $self;
        },

        publish => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            for (keys %values) {
                if ($values{$_} eq "_SET_NULL_") {
                    $values{$_} = undef;
                }
            }

            # Não é possível publicar um candidato que não foi aprovado.
            if ($self->status ne "activated") {
                die \['status', "candidate is not activated."];
            }

            # Não é possível publicar um candidato que ainda não tenha pago o boleto.
            if ($self->payment_status ne "paid") {
                die \['payment_status', "can't publish unpaid candidate."];
            }

            # Validando se o candidato preencheu todos os campos necessários para publicar sua página.
            my @required = qw(
                cnpj video_url summary biography raising_goal public_email picture
            );

            for (@required) {
                if (!$self->$_) {
                    die \[$_, "can't publish until fill '$_'."];
                }
            }

            return $self->update({ publish => 1 });
        },

        unpublish => sub {
            $self->update({ publish => 0 });
        },
    };
}

sub total_donated {
    my $self = shift;

    return $self->donations->search({
        status           => "captured",
        donation_type_id => 1,
        (
            $self->crawlable
            ? ()
            : ( by_votolegal => "true" )
        ),
    })->get_column('amount')->sum();
}

sub total_donated_by_votolegal {
    my $self = shift;

    return $self->donations->search({
        status           => "captured",
        donation_type_id => 1,
        by_votolegal     => "true",
    })->get_column('amount')->sum();
}

sub people_donated {
    my $self = shift;

    return $self->donations->search({
        status           => "captured",
        donation_type_id => 1,
        (
            $self->crawlable
            ? ()
            : ( by_votolegal => "true" )
        ),
    })->count();
}

sub party_fund {
    my $self = shift;

    return 0 unless $self->crawlable;

    return $self->donations->search({
        by_votolegal     => "false",
        donation_type_id => 2,
    })->get_column("amount")->sum;
}

sub send_email_registration {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org.br',
        subject  => "VotoLegal - Cadastro realizado",
        template => get_data_section('candidate_registration.tt'),
        vars     => { map { $_ => $self->$_} qw(name) },
    )->build_email();

    return $self->resultset('EmailQueue')->create({
        body => $email->as_string,
        bcc  => ['contato@votolegal.org.br'],
    });
}

sub send_email_approval {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org',
        subject  => "VotoLegal - Cadastro aprovado",
        template => get_data_section('candidate_approval.tt'),
        vars     => {
            name  => $self->name,
            login => $self->user->email,
        },
    )->build_email();

    return $self->resultset('EmailQueue')->create({
        body => $email->as_string,
    });
}

sub send_email_disapproval {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org',
        subject  => "VotoLegal - Cadastro reprovado",
        template => get_data_section('candidate_disapproval.tt'),
        vars     => { name => $self->name },
    )->build_email();

    return $self->resultset('EmailQueue')->create({
        body => $email->as_string,
    });
}

sub validate_required_information_for_payment {
    my ($self) = @_;

    my @required = qw(
        name address_zipcode address_city address_state address_street address_house_number
    );

    for (@required) {
        if (!defined($self->$_)) {
            die \[$_, "missing"];
        }
    }
}

sub get_phone_number_and_area_code {
    my ($self) = @_;

    my $phone     = $self->phone;
    my $area_code = substr($phone, 0, 2);
    my $number    = substr($phone, 2);

    # Retornando em camel case
    # por ser um param que vai direto
    # para o gateway (por agora PagSeguro).
    return {
        areaCode => $area_code,
        number   => $number,
    }
}

sub get_address_data {
    my ($self) = @_;

    # Retornando em camel case
    # por ser um param que vai direto
    # para o gateway (por agora PagSeguro).

    # Atualmente (10/04/2018) a API do PagSeguro pede o
    # estado como sigla.
    return {
        country    => 'BRA',
        state      => $self->address_state,
        city       => $self->address_city,
        postalCode => $self->address_zipcode,
        street     => $self->address_street,
        district   => $self->address_district,
        number     => $self->address_house_number,
        complement => $self->address_complement,
    }
}

sub candidate_has_paid {
    my ($self) = @_;

    return $self->payment_status eq 'paid' ? 1 : 0;
}

sub candidate_has_payment_created {
    my ($self) = @_;

    my $payment_rs     = $self->result_source->schema->resultset("Payment");

    my $last_payment = $self->payments->search(undef, { max => 'created_at' } )->next;

    my $ret;
    if ($last_payment) {
        my $log = $last_payment->payment_logs->search(undef, { max => 'created_at' } )->next;

        if ($log->status eq 'analysis') {
            $ret = 1;
        }
        else {
            $ret = 0;
        }

    } else {
        $ret = 0
    }


    return $ret;
}

sub has_mandatoaberto_integration {
    my ($self) = @_;

    return $self->candidate_mandato_aberto_integrations->count > 0 ? 1 : 0;
}

sub send_payment_in_analysis_email {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org',
        subject  => "VotoLegal - Pagamento em análise",
        template => get_data_section('payment_analysis.tt'),
        vars     => { name => $self->name },
    )->build_email();

    return $self->resultset('EmailQueue')->create({
        body => $email->as_string,
    });
}

sub send_payment_approved_email {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org',
        subject  => "VotoLegal - Pagamento aprovado",
        template => get_data_section('payment_approved.tt'),
        vars     => { name => $self->name },
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
<!doctype html>
<html>
   <head>
      <meta charset="UTF-8">
   </head>
   <body>
      <div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
         <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
            <tbody>
               <tr>
                  <td>
                     <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
                        <tbody>
                           <tr>
                              <td height="50"></td>
                           </tr>
                           <tr>
                              <td colspan="2"><a href="https://www.votolegal.org.br/" target="_blank"><img src="https://www.votolegal.org.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
                           </tr>
                           <tr>
                              <td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
                                 <table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
                                    <tbody>
                                       <tr>
                                          <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                             <p align="center">
                                                <span>
                                                <b>
                                                Bem-vindo ao Voto Legal.
                                                </b>
                                                <br>
                                                <br>
                                                </span>
                                             </p>
                                             <p>
                                                Seu pré-cadastro foi realizado com sucesso.
                                             </p>
                                             <p>
                                             Faltam poucos passos para contratar o Voto Legal,  para  arrecadação financeira  e construção de campanhas eleitorais transparentes.
                                             </p>
                                             <p>
                                             Receba doações de valores e serviços por uma plataforma que já operou e funcionou em eleições de acordo com a legislação do TSE. Ative o Voto Legal em seu site de campanha e aumente as formas de integração com seu público.
                                             </p>
                                             <p>
                                             <b>Importante:</b> Todos os dados para contratação devem ser do pré-candidato, estando vedada a contratação em nome de terceiros. Se houver divergências ou inconformidades das informações, os valores arrecadados poderão ser devolvidos aos doadores e/ou tesouro nacional.
                                             </p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                          <b>Funcionalidades da Plataforma</b>
                                             <ul>
                                                <li>
                                                   Estrutura para receber doações financeiras e de serviços  para a sua campanha;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Receba doações via cartão de crédito e boleto bancário;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Geração de contrato de serviços em conformidade ao TSE;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Transparência em tempo real em seu site de campanha;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Emissão de recibos de acordo com a legislação;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Integração com o SPCE (sistema de prestação de contas do TSE);
                                                </li>
                                                <p></p>
                                                <li>
                                                    Suporte com especialistas;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Cursos relacionados às estratégias eleitorais na Internet;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Painel de controle para acompanhamento das doações em tempo real;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Plataforma Integrada com diversas operadoras financeiras;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Uso dos melhores protocolos de segurança da informação;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Transparência de dados em formatos abertos;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Suporte para milhares de acessos simultâneos;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Instruções legais e detalhadas para doadores;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Orientação para declaração de imposto de renda e prestação de contas para doadores;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Blockchain (DECRED) para comprovar autenticidade;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Tecnologia contra lavagem de dinheiro com reconhecimento facial para combater fraudes;
                                                </li>
                                             </ul>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                             <p>
                                                <b>Custos da Plataforma</b>
                                             </p>
                                             <p>
                                                O valores para contratação da infraestrutura do Voto Legal são:
                                             </p>
                                             <p>
                                                <b>Pré-campanha (15/05/2018 a 15/08/2018)</b>
                                             </p>
                                             <p>
                                                Parcela única de R$ 495,00 (quatrocentos e noventa e cinco reais) pago no momento da contratação.
                                             </p>
                                             <p>
                                                <b>Campanha (a partir de 15/08/2018)</b>
                                             </p>
                                             <p>
                                                Para os candidatos que <b>não utilizaram</b> o Voto Legal durante a pré-campanha, o valor de contratação na campanha será de R$ 495,00 (quatrocentos e noventa e cinco reais) assim que for emitido o CNPJ da campanha e indicação de conta bancária oficial da candidatura.
Para os candidatos que <b>utilizaram</b> o Voto Legal durante a pré-campanha, o valor de contratação na campanha será é de R$ 99,00 (noventa e nove reais),  que deverão ser pagos em parcela única no momento que for emitido o CNPJ da campanha e indicação de conta bancária oficial da candidatura.
                                             </p>
                                             <p>
                                             <b>Importante:</b> Somente após a confirmação do recebimento desta parcela, através dos meios de pagamento digitais, a plataforma irá liberar o perfil para configuração.
                                             </p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td height="40"></td>
                                       </tr>
                                       <tr>
                                          <td align="center" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px">
                                             <strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
                                                <p>
                                                  <strong>Para finalizar sua contratação <a href="https://www.votolegal.com.br" style="color:#4ab957"><b>clique aqui</b></a>.</strong>
                                                </p>
                                                <strong>
                                                <p dir="ltr">Dúvidas? Acesse <a href="https://www.votolegal.org.br/perguntas-frequentes" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
                                                </strong>
                                                Equipe Voto Legal
                                             </strong>
                                             <a href="mailto:contato@votolegal.org.br" target="_blank" style="color:#4ab957"></a>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td height="30"></td>
                                       </tr>
                                    </tbody>
                                 </table>
                              </td>
                           </tr>
                        </tbody>
                     </table>
                     <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
                        <tbody>
                           <tr>
                              <td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
                                 <span><strong>Voto Legal</strong>- Eleições limpas e transparentes. </span>
                              </td>
                           </tr>
                        </tbody>
                     </table>
                  </td>
               </tr>
            </tbody>
         </table>
      </div>
      </div></div>
@@ candidate_approval.tt
<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://www.votolegal.org.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Olá [% nome %], </b><br>
      <br></span></p>
    <p> <strong> Parabéns, seu cadastro no Voto Legal foi aprovado!</strong></p>
    <p>Agora você pode acessar seu Portal do Candidato e completar seu cadastro. A partir do dia 15.08.2016 o perfil ficará habilitado para receber doações.    </p>
    <p>Seu login: [% login %]</p>
  </td>
</tr>
<tr>
<td height="30"></td>
</tr>
<tr>
<td align="center" bgcolor="#ffffff" valign="top" style="padding-top:20px">
<table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:separate; border-radius:7px; margin:0">
<tbody>
<tr>
<td align="center" valign="middle"><a href="http://participe.votolegal.com.br/" target="_blank" class="x_btn" style="background:#4ab957; border-radius:8px; color:#ffffff; font-family:'Montserrat',Arial,sans-serif; font-size:15px; padding:16px 24px 15px 24px; text-decoration:none; text-transform:uppercase"><strong>COMPLETAR CADASTRO</strong></a></td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
  <p>Já se preparou para o cadastro completo? <a href="https://www.votolegal.org.br/documentos-para-cadastro" target="_blank" style="color:#4ab957">Acesse aqui</a> e visualize os itens necessários para realizar seu cadastro. Lembrando que você tem até o dia 14.08.2016 para deixar seu perfil completo, após essa data, o perfil ficará ativo e as doações começarão e não será possível alterar seu perfil.</p>
  <p>Dúvidas? Acesse <a href="https://www.votolegal.org.br/perguntas-frequentes" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
  Equipe Voto Legal</strong><a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957"></a></td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
  <tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Voto Legal</strong>- Eleições limpas e transparentes. </span></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>
</div></div>
</body>
</html>

@@ candidate_disapproval.tt

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://www.votolegal.org.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Olá [% name %], </b><br>
      <br></span></p>
    <p>Enviamos este e-mail para informar que seu pré-cadastro no Voto Legal <strong>não foi aprovado</strong>. </p>
    <p>Consulte as <a href="https://www.votolegal.org.br/perguntas-frequentes" target="_blank" style="color:#4ab957">perguntas frequentes</a> para conhecer alguns dos motivos para um pré-cadastro não ser aprovado.      </p>
    <p>Entre em contato conosco para obter mais informações <a href="#" target="_blank" style="color:#4ab957">clicando aqui</a>. </p>
    <p><b>Importante:</b> Somente após a confirmação do recebimento desta parcela, através dos meios de pagamento digitais, a plataforma irá liberar o perfil para configuração.</p>
  </td>
</tr>
<tr>
  <td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
  <p>Equipe Voto Legal</p>
</strong><a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957"></a></td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
  <tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Voto Legal</strong>- Eleições limpas e transparentes. </span></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>
</div></div>
</body>
</html>

@@ payment_analysis.tt

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://www.votolegal.org.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Olá [% name %], </b><br>
      <br></span></p>
    <p>Recebemos seu pedido de compra e contratação da plataforma Voto Legal, para  arrecadação financeira  e construção de campanhas eleitorais transparentes.</p>
    <p>Aguardamos a confirmação de pagamento de sua operadora financeira.</p>
    <p>Assim que confirmado, será enviado um novo email.</p>
    <p><b>Importante:</b> Somente após a confirmação do recebimento desta parcela, através dos meios de pagamento digitais, a plataforma irá liberar o perfil para configuração.</p>
  </td>
</tr>
<tr>
  <td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
  <p>Perguntas ou dúvidas? Consulte nosso <a href="https://www.votolegal.org.br/perguntas-frequentes" target="_blank" style="color:#4ab957">FAQ</a> ou envie um email para <a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957">contato@votolegal.com</a></p>
  <p>Equipe Voto Legal</p>
</strong><a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957"></a></td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
  <tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Voto Legal</strong>- Eleições limpas e transparentes. </span></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>
</div></div>
</body>
</html>

@@ payment_approved.tt

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://www.votolegal.org.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Olá [% name %],</b><br>
      <br></span></p>
    <p>Seu pedido de compra e contratação da plataforma Voto Legal foi aprovado!</p>
    <p>Inicie sua pré campanha para  arrecadação financeira  e construção de campanhas eleitorais transparentes.</p>
    <p>Acesse <a href="https://www.votolegal.com.br" target="_blank" style="color:#4ab957">a plataforma</a> e inicie a configuração de seu perfil no Voto Legal.</p>
    <p><b>Importante:</b> Necessário login e senha que foi registrado no pré-cadastro. Casos tenha esquecido, digite o email de login e selecione "esqueci a senha".</p>
    <p><b>Agilize a configuração de seu perfil, tenha estes conteúdos em mãos:</b>
         <ul>
            <li>
                Texto apresentação pré-candidato até 1000 caracteres;
            </li>
                <p></p>
            <li>
                Lista com 4 propósitos prioritários da pré campanha;
            </li>
                <p></p>
            <li>
                Texto até 500 caracteres sobre cada um dos propósitos prioritários;
            </li>
                <p></p>
            <li>
                Defina a meta da pré- campanha de arrecadação financeira;
            </li>
                <p></p>
            <li>
                Vídeo de apresentação da pré-campanha de arrecadação;
            </li>
            <p></p>
            <li>
                Link para redes sociais do pré-candidato;
            </li>
            <p></p>
            <li>
                Foto do pré-candidato.
            </li>
        </ul></p>
  </td>
</tr>
<tr>
  <td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
<p><b>Boa pré-campanha!</b></p>
  <p>Perguntas ou dúvidas? Consulte nosso <a href="https://www.votolegal.org.br/perguntas-frequentes" target="_blank" style="color:#4ab957">FAQ</a> ou envie um email para <a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957">contato@votolegal.com</a></p>
  <p>Equipe Voto Legal</p>
</strong><a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957"></a></td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
  <tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Voto Legal</strong>- Eleições limpas e transparentes. </span></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>
</div></div>
</body>
</html>