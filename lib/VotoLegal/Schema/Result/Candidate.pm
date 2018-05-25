#<<<
use utf8;
package VotoLegal::Schema::Result::Candidate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("candidate");
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
  "google_analytics",
  { data_type => "text", is_nullable => 1 },
  "collect_donor_address",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "collect_donor_phone",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "campaign_donation_type",
  {
    data_type     => "text",
    default_value => "pre-campaign",
    is_nullable   => 0,
    original      => { data_type => "varchar" },
  },
  "use_certiface_return_url_id",
  {
    data_type      => "integer",
    default_value  => 1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "emaildb_config_id",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "min_donation_value",
  { data_type => "integer", default_value => 2000, is_nullable => 0 },
  "is_published",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "running_for_address_state",
  { data_type => "text", is_nullable => 1 },
  "published_at",
  { data_type => "timestamp", is_nullable => 1 },
  "unpublished_at",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("candidate_cpf_key", ["cpf"]);
__PACKAGE__->add_unique_constraint("candidate_username_key", ["username"]);
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
__PACKAGE__->might_have(
  "candidate_campaign_config",
  "VotoLegal::Schema::Result::CandidateCampaignConfig",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->might_have(
  "candidate_donation_summary",
  "VotoLegal::Schema::Result::CandidateDonationSummary",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "candidate_issue_priorities",
  "VotoLegal::Schema::Result::CandidateIssuePriority",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "candidate_mandato_aberto_integrations",
  "VotoLegal::Schema::Result::CandidateMandatoAbertoIntegration",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "donations",
  "VotoLegal::Schema::Result::Donation",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "expenditures",
  "VotoLegal::Schema::Result::Expenditure",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "office",
  "VotoLegal::Schema::Result::Office",
  { id => "office_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "party",
  "VotoLegal::Schema::Result::Party",
  { id => "party_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
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
__PACKAGE__->has_many(
  "payments",
  "VotoLegal::Schema::Result::Payment",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
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
__PACKAGE__->has_many(
  "projects",
  "VotoLegal::Schema::Result::Project",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "use_certiface_return_url",
  "VotoLegal::Schema::Result::CertifaceReturnUrl",
  { id => "use_certiface_return_url_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "user",
  "VotoLegal::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->has_many(
  "votolegal_donations",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { "foreign.candidate_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->many_to_many(
  "issue_priorities",
  "candidate_issue_priorities",
  "issue_priority",
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-25 09:50:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mtVzvjzlZ7Is0OpTTys/jw

use File::Temp q(:seekable);
use Data::Verifier;
use Data::Validate::URI qw(is_web_uri);
use Template;
use Business::BR::CEP qw(test_cep);
use VotoLegal::Utils;
use VotoLegal::Types qw(EmailAddress CPF PositiveInt CommonLatinText);
use VotoLegal::Mailer::Template;
use MooseX::Types::CNPJ qw(CNPJ);
use Data::Section::Simple qw(get_data_section);

with 'VotoLegal::Role::Verification';
with 'VotoLegal::Role::Verification::TransactionalActions::DBIC';

sub address_state_code {
    my $self = shift;

    my $state = $self->resultset('State')->search( { name => $self->address_state } )->next;
    if ($state) {
        return $state->code;
    }
    return;
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
                    required   => 0,
                    type       => CommonLatinText,
                    max_length => 100,
                    post_check => sub {
                        my $name = $_[0]->get_value('name');

                        scalar( split( m{ }, $name ) ) > 1;
                    },
                },
                popular_name => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                party_id => {
                    required   => 0,
                    type       => PositiveInt,
                    post_check => sub {
                        my $r = shift;

                        $self->result_source->schema->resultset('Party')->search( { id => $r->get_value('party_id') } )
                          ->count;
                    },
                },
                cpf => {
                    required   => 0,
                    max_length => 14,
                    type       => CPF,
                    post_check => sub {
                        my $r = shift;

                        $self->resultset( $self->result_source->source_name )->search(
                            {
                                cpf     => $r->get_value('cpf'),
                                user_id => { '!=' => $self->user_id },
                            }
                          )->count
                          and die \[ "cpf", "already exists" ];

                        return 1;
                    },
                },
                phone => {
                    required   => 0,
                    max_length => 11,
                    type       => "Str",
                    post_check => sub {
                        my $r     = shift;
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
                        if ( !grep $_ eq 'admin', @$roles ) {
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
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $state = $r->get_value('address_state');
                        $self->resultset('State')->search( { code => $state } )->count;
                    },
                },
                address_city => {
                    required   => 0,
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $city = $r->get_value('address_city');
                        $self->resultset('City')->search( { name => $city } )->count;
                    },
                },
                address_zipcode => {
                    required   => 0,
                    max_length => 9,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $cep = $r->get_value('address_zipcode');
                        return test_cep($cep);
                    },
                },
                address_street => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                address_house_number => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                    type_check => sub {
                        my $address_house_number = $_[0]->get_value('address_house_number');
                        $address_house_number =~ m{^\d+$};
                    },
                },
                address_complement => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                address_district => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                cnpj => {
                    required   => 0,
                    max_length => 20,
                    type       => CNPJ,
                },
                issue_priorities => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $issue_priorities = $r->get_value("issue_priorities");
                        my @issue_priority_ids = grep { int($_) == $_ } split( m{\s*,\s*}, $issue_priorities );

                        if ( @issue_priority_ids > 4 ) {
                            return 0;
                        }

                        my @issue_priority = map {
                            $self->resultset('IssuePriority')->find($_)
                              or die \[ "issue_priorities", "invalid issue_priority_id '$_'" ]
                        } @issue_priority_ids;

                        $self->set_issue_priorities(@issue_priority);

                        return 1;
                    },
                },
                picture => {
                    required   => 0,
                    max_length => 1024,
                    type       => "Str",
                    post_check => sub { is_web_uri $_[0]->get_value('picture') },
                },
                video_url => {
                    required   => 0,
                    max_length => 1024,
                    type       => "Str",
                    post_check => sub {
                        my $video_url = $_[0]->get_value('video_url');

                        return 1 if $video_url eq "_SET_NULL_";
                        die \[ 'video_url', 'invalid' ]
                          unless $video_url =~
/^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))?((?:vimeo\.com))?(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$/;
                    },
                },
                facebook_url => {
                    required   => 0,
                    max_length => 1024,
                    type       => "Str",
                    post_check => sub {
                        my $facebook_url = $_[0]->get_value('facebook_url');
                        return 1 if $facebook_url eq "_SET_NULL_";
                        is_web_uri $facebook_url;
                    },
                },
                twitter_url => {
                    required   => 0,
                    max_length => 1024,
                    type       => "Str",
                    post_check => sub {
                        my $twitter_url = $_[0]->get_value('twitter_url');
                        return 1 if $twitter_url eq "_SET_NULL_";
                        is_web_uri $twitter_url;
                    },
                },
                website_url => {
                    required   => 0,
                    max_length => 1024,
                    type       => "Str",
                    post_check => sub {
                        my $website_url = $_[0]->get_value('website_url');
                        return 1 if $website_url eq "_SET_NULL_";
                        is_web_uri $website_url;
                    },
                },
                summary => {
                    required   => 0,
                    max_length => 1024 * 100,
                    type       => "Str",
                },
                biography => {
                    required   => 0,
                    max_length => 1024 * 100,
                    type       => "Str",
                },
                instagram_url => {
                    required   => 0,
                    max_length => 1024,
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
                    required   => 0,
                    max_length => 100,
                    type       => EmailAddress,
                },
                spending_spreadsheet => {
                    required   => 0,
                    max_length => 1024,
                    type       => "Str",
                },
                responsible_name => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                responsible_email => {
                    required   => 0,
                    max_length => 100,
                    type       => EmailAddress,
                },
                merchant_id => {
                    required => 0,
                    type     => "Str",
                },
                merchant_key => {
                    required   => 0,
                    max_length => 100,
                    type       => "Str",
                },
                payment_gateway_id => {
                    required   => 0,
                    type       => PositiveInt,
                    post_check => sub {
                        my $r = shift;

                        my $payment_gateway_id = $r->get_value('payment_gateway_id');
                        $self->resultset('PaymentGateway')->find($payment_gateway_id);
                    },
                },
                bank_code => {
                    required   => 0,
                    type       => PositiveInt,
                    post_check => sub {
                        my $r = shift;

                        my $bank_code = $r->get_value('bank_code');
                        $self->resultset('Bank')->find($bank_code);
                    },
                },
                bank_agency => {
                    required   => 0,
                    required   => 0,
                    type       => "Str",
                    max_length => 20,
                    post_check => sub {
                        my $test = $_[0]->get_value('bank_agency');
                        return 1 if $test eq "_SET_NULL_";

                        $test =~ m{^\d+$};
                    },
                },
                bank_agency_dv => {
                    required   => 0,
                    required   => 0,
                    type       => "Str",
                    max_length => 20,
                    post_check => sub {
                        my $test = $_[0]->get_value('bank_agency_dv');
                        return 1 if $test eq "_SET_NULL_";

                        $test =~ m{^\d+$};
                    },
                },
                bank_account_number => {
                    required   => 0,
                    type       => "Str",
                    max_length => 20,
                    post_check => sub {
                        my $test = $_[0]->get_value('bank_account_number');
                        return 1 if $test eq "_SET_NULL_";

                        $test =~ m{^\d+$};
                    },
                },
                bank_account_dv => {
                    required   => 0,
                    type       => "Str",
                    max_length => 20,
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
                    required   => 0,
                    max_length => 100,
                    type       => "Str"
                },
                political_movement_id => {
                    required   => 0,
                    type       => PositiveInt,
                    post_check => sub {
                        my $political_movement_id = $_[0]->get_value('political_movement_id');

                        my $political_movement = $self->result_source->schema->resultset('PoliticalMovement')
                          ->search( { id => $political_movement_id } )->next;

                        die \[ 'political_movement_id', 'could not find political movement with that id' ]
                          unless $political_movement;
                    }
                },
                google_analytics => {
                    required   => 0,
                    max_length => 35,
                    type       => "Str",
                    post_check => sub {
                        my $google_analytics = $_[0]->get_value('google_analytics');

                        die \[ 'google_analytics', 'invalid id' ] unless $google_analytics =~ /^UA-\d{1,30}-\d{1}$/;

                        return 1;
                    }
                },
                collect_donor_address => {
                    required => 0,
                    type     => "Bool"
                },
                collect_donor_phone => {
                    required => 0,
                    type     => "Bool"
                },
                running_for_address_state => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $address_state = $_[0]->get_value('running_for_address_state');

                        my $state = $self->result_source->schema->resultset('State')
                          ->search( { name => $address_state } )->next;

                        die \[ 'running_for_address_state', 'could not find state with that name' ]
                          unless $state;
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

            for ( keys %values ) {
                if ( $values{$_} eq "_SET_NULL_" ) {
                    $values{$_} = undef;
                }
            }

            # Deletando os values que não pertencem a entidade Candidate.
            delete $values{roles};
            delete $values{issue_priorities};

            if (%values) {
                $self = $self->update( \%values );
            }

            return $self;
        },

        publish => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            for ( keys %values ) {
                if ( $values{$_} eq "_SET_NULL_" ) {
                    $values{$_} = undef;
                }
            }

            # Não é possível publicar um candidato que não foi aprovado.
            if ( $self->status ne "activated" ) {
                die \[ 'status', "candidate is not activated." ];
            }

            # Não é possível publicar um candidato que ainda não tenha pago o boleto.
            if ( $self->payment_status ne "paid" ) {
                die \[ 'payment_status', "can't publish unpaid candidate." ];
            }

            # Validando se o candidato preencheu todos os campos necessários para publicar sua página.

            # TODO adicionar cnpj
            my @required = qw(
              video_url summary biography raising_goal public_email picture
            );

            for (@required) {
                if ( !$self->$_ ) {
                    die \[ $_, "can't publish until fill '$_'." ];
                }
            }

            return $self->update(
              {
                is_published => 1,
                published_at => \'coalesce(published_at, NOW())'
              }
            );
        },

        unpublish => sub {
            $self->update(
                {
                    is_published   => 0,
                    unpublished_at => \'NOW()'
                }
            );
        },
    };
}

sub total_donated {
    my $self = shift;

    return $self->candidate_donation_summary->amount_donation_by_votolegal +
      $self->candidate_donation_summary->amount_donation_beside_votolegal;
}

sub total_donated_by_votolegal {
    my $self = shift;

    return $self->candidate_donation_summary->amount_donation_by_votolegal;
}

sub people_donated {
    my $self = shift;

    return $self->candidate_donation_summary->count_donation_by_votolegal +
      $self->candidate_donation_summary->count_donation_beside_votolegal;
}

sub party_fund {
    my $self = shift;

    return 0;

    # disabled for now.. shoulbe be on candidate_donation_summary

    return 0 unless $self->crawlable;

    return $self->donations->search(
        {
            by_votolegal     => "false",
            donation_type_id => 2,
        }
    )->get_column("amount")->sum;
}

sub send_email_registration {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org.br',
        subject  => "VotoLegal - Cadastro realizado",
        template => get_data_section('candidate_registration.tt'),
        vars     => { map { $_ => $self->$_ } qw(name) },
    )->build_email();

    return $self->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
            bcc  => ['contato@votolegal.org.br'],
        }
    );
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

    return $self->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
        }
    );
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

    return $self->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
        }
    );
}

sub validate_required_information_for_payment {
    my ($self) = @_;

    my @required = qw(
      name address_zipcode address_city address_state address_street address_house_number
    );

    for (@required) {
        if ( !defined( $self->$_ ) ) {
            die \[ $_, "missing" ];
        }
    }
}

sub get_phone_number_and_area_code {
    my ($self) = @_;

    my $phone     = $self->phone;
    my $area_code = substr( $phone, 0, 2 );
    my $number    = substr( $phone, 2 );

    # Retornando em camel case
    # por ser um param que vai direto
    # para o gateway (por agora PagSeguro).
    return {
        areaCode => $area_code,
        number   => $number,
    };
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
    };
}

sub candidate_has_paid {
    my ($self) = @_;

    return $self->payment_status eq 'paid' ? 1 : 0;
}

sub candidate_has_payment_created {
    my ($self) = @_;

    my @payments = $self->payments->all();

    my $most_recent_payment = $self->payments->search( undef, { order_by => { '-desc' => 'created_at' } } )->first;
    return 0 unless $most_recent_payment;

    my $most_recent_payment_log =
      $most_recent_payment->payment_logs->search( undef, { order_by => { '-desc' => 'created_at' } } )->first;

    if ( $most_recent_payment_log
        && ( $most_recent_payment_log->status eq 'analysis' || $most_recent_payment_log->status eq 'captured' ) ) {
        return 1;
    }
    else {
        return 0;
    }
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

    return $self->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
        }
    );
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

    return $self->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
        }
    );
}

sub send_payment_not_approved_email {
    my ($self) = @_;

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@votolegal.org',
        subject  => "VotoLegal - Pagamento reprovado",
        template => get_data_section('payment_not_approved.tt'),
        vars     => { name => $self->name },
    )->build_email();

    return $self->resultset('EmailQueue')->create(
        {
            body => $email->as_string,
        }
    );
}

sub get_most_recent_payment {
    my ($self) = @_;

    my $payment = $self->payments->search( undef, { order_by => [ { '-desc' => 'created_at' } ] } )->next;

    return $payment ? $payment : 0;
}

sub get_account_payment_status {
    my ($self) = @_;

    my $payment_status = $self->payment_status;

    my $ret;
    if ( $payment_status eq 'unpaid' ) {

        if ( my $payment = $self->get_most_recent_payment() ) {
            my $log = $payment->payment_logs->search( undef, { order_by => [ { '-desc' => 'created_at' } ] } )->next;

            if ( $log && ( $log->status eq 'analysis' || $log->status eq 'created' ) ) {
                $ret = 'pagamento em análise';
            }
            elsif ( $log && $log->status eq 'failed' ) {
                $ret = 'pagamento recusado';
            }

        }
        else {
            $ret = 'não criou pagamento';
        }
    }
    else {

        $ret = 'pagamento aprovado';
    }

    return $ret;
}

sub cpf_formated {
    my ($self) = @_;

    my $cpf = $self->get_column('cpf');
    return '' unless $cpf;
    $cpf =~ s/[^0-9]+//g;
    $cpf =~ s/^(...)(...)(...)(..).*/$1.$2.$3-$4/;
    return $cpf;
}

sub cnpj_formated {
    my ($self) = @_;

    my $cnpj = $self->get_column('cnpj');
    return '' unless $cnpj;
    $cnpj =~ s/[^0-9]+//g;
    $cnpj =~ s|^(..)(...)(...)(....)(..).*|$1.$2.$3/$4-$5|;

    return $cnpj;
}

sub recalc_summary {
    my ( $self, $c ) = @_;

    $self->candidate_donation_summary->update(
        {

            amount_donation_by_votolegal => \[
"coalesce( ( SELECT SUM(b.amount) FROM votolegal_donation a JOIN votolegal_donation_immutable b on b.votolegal_donation_id = a.id
            WHERE captured_at IS NOT NULL AND refunded_at IS NULL AND candidate_id = ? ), 0)", $self->id
            ],

            count_donation_by_votolegal => \[
                "( SELECT count(1) FROM votolegal_donation
            WHERE captured_at IS NOT NULL AND refunded_at IS NULL AND candidate_id = ? )", $self->id
            ],

            amount_donation_beside_votolegal => \[
                "coalesce( ( SELECT SUM( amount ) FROM donation
            WHERE status = 'captured' AND candidate_id = ? ), 0)", $self->id
            ],

            count_donation_beside_votolegal => \[
                "( SELECT count(1) FROM donation
            WHERE status = 'captured' AND candidate_id = ? )", $self->id
            ],

        }
    );

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
                              <td colspan="2"><a href="https://www.votolegal.com.br/" target="_blank"><img src="https://gallery.mailchimp.com/d3a90e0e7418b8c4e14997e44/images/fec4013c-fb33-4220-9a25-f0adfd89f971.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
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
                                                Seu pr&#233;-cadastro foi realizado com sucesso.
                                             </p>
                                             <p>
                                             Faltam poucos passos para contratar o Voto Legal,  para  arrecada&#231;&#227;o financeira  e constru&#231;&#227;o de campanhas eleitorais transparentes.
                                             </p>
                                             <p>
                                             Receba doa&#231;&#245;es de valores e servi&#231;os por uma plataforma que j&#225; operou e funcionou em elei&#231;&#245;es de acordo com a legisla&#231;&#227;o do TSE. Ative o Voto Legal em seu site de campanha e aumente as formas de integra&#231;&#227;o com seu p&#250;blico.
                                             </p>
                                             <p>
                                             <b>Importante:</b> Todos os dados para contrata&#231;&#227;o devem ser do pr&#233;-candidato, estando vedada a contrata&#231;&#227;o em nome de terceiros. Se houver diverg&#234;ncias ou inconformidades das informa&#231;&#245;es, os valores arrecadados poder&#227;o ser devolvidos aos doadores e/ou tesouro nacional.
                                             </p>
                                          </td>
                                       </tr>
                                       <tr>
                                          <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                          <b>Funcionalidades da Plataforma</b>
                                             <ul>
                                                <li>
                                                   Estrutura para receber doa&#231;&#245;es financeiras e de servi&#231;os  para a sua campanha;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Receba doa&#231;&#245;es via cart&#227;o de cr&#233;dito e boleto banc&#225;rio;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Gera&#231;&#227;o de contrato de servi&#231;os em conformidade ao TSE;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Transpar&#234;ncia em tempo real em seu site de campanha;
                                                </li>
                                                    <p></p>
                                                <li>
                                                    Emiss&#227;o de recibos de acordo com a legisla&#231;&#227;o;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Integra&#231;&#227;o com o SPCE (sistema de presta&#231;&#227;o de contas do TSE);
                                                </li>
                                                <p></p>
                                                <li>
                                                    Painel de controle para acompanhamento das doa&#231;&#245;es em tempo real;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Uso dos melhores protocolos de seguran&#231;a da informa&#231;&#227;o;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Transpar&#234;ncia de dados em formatos abertos;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Suporte para milhares de acessos simult&#226;neos;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Instru&#231;&#245;es legais e detalhadas para doadores;
                                                </li>
                                                <p></p>
                                                <li>
                                                    Orienta&#231;&#227;o para declara&#231;&#227;o de imposto de renda e presta&#231;&#227;o de contas para doadores;
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
                                             <b>Importante:</b> Somente ap&#243;s a confirma&#231;&#227;o do recebimento desta parcela, atrav&#233;s dos meios de pagamento digitais, a plataforma ir&#225; liberar o perfil para configura&#231;&#227;o.
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
                                                  <strong>Para finalizar sua contrata&#231;&#227;o <a href="https://www.votolegal.com.br" style="color:#4ab957"><b>clique aqui</b></a>.</strong>
                                                </p>
                                                <strong>
                                                <p dir="ltr">D&#250;vidas? Acesse <a href="https://www.votolegal.com.br/perguntas-frequentes" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
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
                                 <span><strong>Voto Legal</strong>- Elei&#231;&#245;es limpas e transparentes. </span>
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
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://gallery.mailchimp.com/d3a90e0e7418b8c4e14997e44/images/fec4013c-fb33-4220-9a25-f0adfd89f971.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
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
  <p>Já se preparou para o cadastro completo? <a href="https://www.votolegal.com.br/documentos-para-cadastro" target="_blank" style="color:#4ab957">Acesse aqui</a> e visualize os itens necessários para realizar seu cadastro. Lembrando que você tem até o dia 14.08.2016 para deixar seu perfil completo, após essa data, o perfil ficará ativo e as doações começarão e não será possível alterar seu perfil.</p>
  <p>Dúvidas? Acesse <a href="https://www.votolegal.com.br/perguntas-frequentes" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
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
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://www.votolegal.com.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
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
    <p>Consulte as <a href="https://www.votolegal.com.br/perguntas-frequentes" target="_blank" style="color:#4ab957">perguntas frequentes</a> para conhecer alguns dos motivos para um pré-cadastro não ser aprovado.      </p>
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
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://gallery.mailchimp.com/d3a90e0e7418b8c4e14997e44/images/fec4013c-fb33-4220-9a25-f0adfd89f971.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Ol&#225;, [% name %]. </b><br>
      <br></span></p>
    <p>Recebemos seu pedido de compra e contrata&#231;&#227;o da plataforma Voto Legal, para  arrecada&#231;&#227;o financeira  e constru&#231;&#227;o de campanhas eleitorais transparentes.</p>
    <p>Aguardamos a confirma&#231;&#227;o de pagamento de sua operadora financeira.</p>
    <p>Assim que confirmado, ser&#225; enviado um novo email.</p>
    <p><b>Importante:</b> Somente ap&#243;s a confirma&#231;&#227;o do recebimento desta parcela, atrav&#233;s dos meios de pagamento digitais, a plataforma ir&#225; liberar o perfil para configura&#231;&#227;o.</p>
  </td>
</tr>
<tr>
  <td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
  <p>Perguntas ou d&#250;vidas? Consulte nosso <a href="https://www.votolegal.com.br/perguntas-frequentes" target="_blank" style="color:#4ab957">FAQ</a> ou envie um email para <a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957">contato@votolegal.com</a></p>
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
<span><strong>Voto Legal</strong>- Elei&#231;&#245;es limpas e transparentes. </span></td>
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
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://gallery.mailchimp.com/d3a90e0e7418b8c4e14997e44/images/fec4013c-fb33-4220-9a25-f0adfd89f971.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Ol&#225;, [% name %].</b><br>
      <br></span></p>
    <p>Seu pedido de compra e contrata&#231;&#227;o da plataforma Voto Legal foi aprovado!</p>
    <p>Inicie sua pr&#233; campanha para  arrecada&#231;&#227;o financeira  e constru&#231;&#227;o de campanhas eleitorais transparentes.</p>
    <p>Acesse <a href="https://www.votolegal.com.br" target="_blank" style="color:#4ab957">a plataforma</a> e inicie a configura&#231;&#227;o de seu perfil no Voto Legal.</p>
    <p><b>Importante:</b> Necess&#225;rio login e senha que foi registrado no pr&#233;-cadastro. Casos tenha esquecido, digite o email de login e selecione "esqueci a senha".</p>
    <p><b>Agilize a configura&#231;&#227;o de seu perfil, tenha estes conte&#250;dos em m&#227;os:</b>
         <ul>
            <li>
                Texto apresenta&#231;&#227;o pr&#233;-candidato at&#233; 1000 caracteres;
            </li>
                <p></p>
            <li>
                Lista com 4 prop&#243;sitos priorit&#225;rios da pr&#233; campanha;
            </li>
                <p></p>
            <li>
                Texto at&#233; 500 caracteres sobre cada um dos prop&#243;sitos priorit&#225;rios;
            </li>
                <p></p>
            <li>
                Defina a meta da pr&#233;- campanha de arrecada&#231;&#227;o financeira;
            </li>
                <p></p>
            <li>
                V&#237;deo de apresenta&#231;&#227;o da pr&#233;-campanha de arrecada&#231;&#227;o;
            </li>
            <p></p>
            <li>
                Link para redes sociais do pr&#233;-candidato;
            </li>
            <p></p>
            <li>
                Foto do pr&#233;-candidato.
            </li>
        </ul></p>
  </td>
</tr>
<tr>
  <td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
<p><b>Boa pr&#233;-campanha!</b></p>
  <p>Perguntas ou d&#250;vidas? Consulte nosso <a href="https://www.votolegal.com.br/perguntas-frequentes" target="_blank" style="color:#4ab957">FAQ</a> ou envie um email para <a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957">contato@votolegal.com</a></p>
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
<span><strong>Voto Legal</strong>- Elei&#231;&#245;es limpas e transparentes. </span></td>
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

@@ payment_not_approved.tt

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
<td colspan="2"><a href="https://votolegal.org.br/"><img src="https://gallery.mailchimp.com/d3a90e0e7418b8c4e14997e44/images/fec4013c-fb33-4220-9a25-f0adfd89f971.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Ol&#225;, [% name %].</b><br>
      <br></span></p>
    <p>Seu pedido de compra da plataforma Voto Legal n&#227;o foi conclu&#237;do.</p>
    <p>Por favor, verifique-se com sua institui&#231;&#227;o financeira e tente realizar o pagamento da plataforma novamente.</p>
    <p>Para reiniciar a contrata&#231;&#227;o, basta logar-se novamente.</p>
    <p><b>Importante:</b> Necess&#225;rio login e senha que foi registrado no pr&#233;-cadastro. Casos tenha esquecido, digite o email de login e selecione "esqueci a senha".</p>
  </td>
</tr>
<tr>
  <td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
  <p>Perguntas ou d&#250;vidas? Consulte nosso <a href="https://www.votolegal.com.br/perguntas-frequentes" target="_blank" style="color:#4ab957">FAQ</a> ou envie um email para <a href="mailto:suporte@votolegal.org.br" target="_blank" style="color:#4ab957">contato@votolegal.com</a></p>
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
<span><strong>Voto Legal</strong>- Elei&#231;&#245;es limpas e transparentes. </span></td>
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
