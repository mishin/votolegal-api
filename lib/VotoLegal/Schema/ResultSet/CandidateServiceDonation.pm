package VotoLegal::Schema::ResultSet::CandidateServiceDonation;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use VotoLegal::Types qw(PositiveInt);

use Data::Verifier;
use Business::BR::CEP qw(test_cep);

sub verifiers_specs {
	my $self = shift;

	return {
		create => Data::Verifier->new(
			filters => [qw(trim)],
			profile => {
				candidate_id => {
					required   => 1,
					type       => 'Int',
					post_check => sub {
						my $candidate_id = $_[0]->get_value('candidate_id');

                        my $candidate_rs = $self->result_source->schema->resultset("Candidate");

                        die \['candidate_id', 'could not find candidate without that id'] if $candidate_rs->search( { id => $candidate_id } )->count == 0;

						return 1;
					}
				},
				equivalent_amount => {
                    required => 1,
                    type     => 'Int'
                },
                name => {
                    required   => 1,
                    type       => 'Str',
                    max_length => 100
                },
                vacancies => {
                    required   => 1,
                    type       => PositiveInt,
                },
                description => {
                    required   => 1,
                    type       => 'Str',
                    max_length => 200
                },
                procedure => {
                    required   => 1,
                    type       => 'Str',
                    max_length => 400
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
                    type       => 'Str',
                },
                address_number => {
                    required => 1,
                    type     => PositiveInt,
                },
                address_complement => {
                    required   => 0,
                    max_length => 100,
                    type       => 'Str',
                },
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

			my $contract_signature = $self->create( \%values );

			$contract_signature->user->send_email_contract_signed();

			return $contract_signature;
		},
	};
}

1;
