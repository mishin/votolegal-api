package VotoLegal::Schema::ResultSet::Candidate;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';
with 'VotoLegal::Role::Verification::TransactionalActions::DBIC';

use Business::BR::CEP qw(test_cep);
use VotoLegal::Types qw(EmailAddress CPF PositiveInt CommonLatinText);

use VotoLegal::Utils qw/remote_notify is_test/;

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                email => {
                    required   => 1,
                    type       => EmailAddress,
                    max_length => 100,
                    filters    => [qw(lower)],
                    post_check => sub {
                        my $r = shift;

                        $self->result_source->schema->resultset('User')->search(
                            {
                                email => $r->get_value('email'),
                            }
                          )->count
                          and die \[ "email", "already exists" ];

                        return 1;
                    }
                },
                password => {
                    required   => 1,
                    max_length => 100,
                    type       => 'Str',
                },
                username => {
                    required   => 1,
                    max_length => 100,
                    type       => "Str",
                    filters    => [qw(lower)],
                    post_check => sub {
                        my $r = shift;

                        my $username = $r->get_value('username');

                        $username =~ m{^[a-z0-9_-]+$} or die \[ 'username', 'invalid characters' ];

                        # api/www/badges
                        return 0 if $username =~ /^(www(\d+)?|ftp|email|.?api|.*badges.*)$/i;

                        if ( $username !~ m{[a-z]} ) {
                            die \[ 'username', "must have letters" ];
                        }

                        # Menos de 4 caracteres.
                        die \[ 'username', 'too short' ] if length $username < 4;

                        # Só numeros.
                        return 0 if $username =~ /^([0-9]+)$/i;

                        # Inicia com número.
                        return 0 if $username =~ /^\d/i;

                        $self->search( { username => { 'ilike' => $username } } )->count
                          and die \[ "username", "already exists" ];

                        return 1;
                    },
                },
                name => {
                    required   => 1,
                    max_length => 100,
                    type       => CommonLatinText,
                    post_check => sub {
                        my $name = $_[0]->get_value('name');

                        scalar( split( m{ }, $name ) ) > 1;
                    },
                },
                popular_name => {
                    required   => 1,
                    max_length => 100,
                    type       => CommonLatinText,
                },

                running_for_address_state => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $address_state = $_[0]->get_value('running_for_address_state');

                        my $state =
                          $self->result_source->schema->resultset('State')->search( { code => $address_state } )->next;

                        die \[ 'running_for_address_state', 'could not find state with that name' ]
                          unless $state;
                    }
                },

                party_id => {
                    required   => 1,
                    type       => PositiveInt,
                    post_check => sub {
                        my $r        = shift;
                        my $party_id = $r->get_value('party_id');

                        $self->result_source->schema->resultset('Party')->search( { id => $party_id } )->count;
                    },
                },
                cpf => {
                    required   => 1,
                    max_length => 14,
                    type       => CPF,
                    post_check => sub {
                        my $r = shift;

                        $self->search(
                            {
                                cpf => $r->get_value('cpf'),
                            }
                          )->count
                          and die \[ "cpf", "already exists" ];

                        return 1;
                    },
                },
                office_id => {
                    required   => 1,
                    type       => PositiveInt,
                    post_check => sub {
                        my $r         = shift;
                        my $office_id = $r->get_value('office_id');

                        $self->result_source->schema->resultset('Office')->search( { id => $office_id } )->count;
                    },
                },

                reelection => {
                    required => 1,
                    type     => 'Bool',
                },
                address_state => {
                    required   => 1,
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $state = $r->get_value('address_state');
                        $self->result_source->schema->resultset('State')->search( { code => $state } )->count;
                    },
                },
                address_city => {
                    required   => 1,
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $city = $r->get_value('address_city');
                        $self->result_source->schema->resultset('City')->search( { name => $city } )->count;
                    },
                },
                address_zipcode => {
                    required   => 1,
                    max_length => 9,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $cep = $r->get_value('address_zipcode');

                        return test_cep($cep);
                    },
                },
                address_street => {
                    required   => 1,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                address_house_number => {
                    required => 1,
                    type     => PositiveInt,
                },
                address_complement => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                birth_date => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $birth_date = $_[0]->get_value('birth_date');

                        die \[ 'birth_date', 'invalid format, must be "dd/mm/aaaa"' ]
                          unless $birth_date =~ /^(\d{2}\/){2}\d{4}$/;

                        return 1;
                    }
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
                }
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;
            $values{status} = 'pending';

            if ( $values{office_id} != 4 ) {
                $values{running_for_address_state} ||= $values{address_state};
            }

            # Creating user.
            my %user;
            $user{$_} = delete $values{$_} for qw(email password);

            $user{email} = $user{email};

            my $user = $self->result_source->schema->resultset('User')->create( \%user );
            $user->add_to_roles( { id => 2 } );

            # Creating candidate.
            my $candidate = $user->candidates->create( \%values );

            return $candidate;
        },
    };
}

sub get_candidates_with_data_for_admin {
    my ($self) = @_;

    return $self->search(
        {
            -and => [
                'user.email' => { 'NOT ILIKE' => '%eokoe%' },
                'user.email' => { 'NOT ILIKE' => '%appcivico%' },
                'user.email' => { 'NOT ILIKE' => '%+%' },
                'me.name'    => { 'NOT ILIKE' => '%Thiago Rondon%' },
                'me.name'    => { 'NOT ILIKE' => '%Lucas Ansei%' },
                'me.name'    => { 'NOT ILIKE' => '%Hernani Mattos%' },
                'me.name'    => { 'NOT ILIKE' => '%Evelyn Perez%' },
                'me.name'    => { 'NOT ILIKE' => '%Edgard Lobo%' },
            ]
        },
        { prefetch => [qw/ party office political_movement payments user /] }
    );
}

sub create_pending_pre_campaign_julios_account {
    my ($self) = @_;

    return unless $ENV{JULIOS_URL};

    my $rs = $self->search(
        {
            'candidate_campaign_config.pre_campaign_julios_customer_id'     => undef,
            'candidate_campaign_config.pre_campaign_julios_customer_errmsg' => undef,
        },
        {
            prefetch => 'candidate_campaign_config',
        }
    );
    my $ws = WebService::Julios->instance;

    while ( my $candidate = $rs->next ) {

        my $cand_conf = $candidate->candidate_campaign_config;

        my $res = eval { $ws->new_customer( { name => $candidate->name, api_key => $ENV{JULIOS_API_KEY}, } ) };

        if ($@) {
            $cand_conf->update( { pre_campaign_julios_customer_errmsg => $@ } );
            remote_notify($@) unless is_test();
        }
        else {

            $cand_conf->update( { pre_campaign_julios_customer_id => $res->{customer}{id} } );

        }

    }

}

1;
