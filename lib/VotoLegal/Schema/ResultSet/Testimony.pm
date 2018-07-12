package VotoLegal::Schema::ResultSet::Testimony;
use Moose;
use namespace::autoclean;
use utf8;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Data::Verifier;


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

                        $self->result_source->schema->resultset('Candidate')->search( { id => $candidate_id } )->count;
                    }
				},
				reviewer_name => {
					required   => 1,
					type       => 'Str',
                    max_length => 100
				},
				reviewer_picture => {
					required => 0,
					type     => 'Str'
				},
				reviewer_text => {
					required   => 1,
					type       => 'Str',
				},
                active => {
                    required => 0,
                    type     => 'Bool'
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

            my $testimony = $self->create(\%values);

            return $testimony;
		},
	};
}

1;
