package VotoLegal::Worker::Serpro;
use strict;
use warnings;
use Moose;

use JSON::MaybeXS;

with 'VotoLegal::Worker';

use WebService::Serpro;

has 'timer' => (
	is      => 'rw',
	default => 30 * 60,    # 30 min.
);

has 'schema' => (
	is       => 'rw',
	required => 1,
);

has 'serpro' => (
	is      => 'rw',
	lazy    => 1,
	builder => '_build_serpro',
);


sub listen_queue {
	my $self = shift;

	$self->logger->info("Buscando itens na fila...") if $self->has_log;

	my $queue_rs = $self->queue_rs;

	my $count = $queue_rs->count;

	if ( $count > 0 ) {
		$self->logger->info("Há '$count' itens na fila para serem processados.") if $self->has_log;

		while ( my $donation = $queue_rs->next() ) {
			$self->exec_item($donation);
		}
	}else {
		$self->logger->info("Nenhum item na fila.") if $self->has_log;
	}
}


sub queue_rs {
	my $self = shift;

	return $self->schema->resultset('VotolegalDonation')->search(
		{
			'me.refunded_at'                         => undef,
			'me.captured_at'                         => { '!=' => undef },
			'votolegal_donation_immutable.donor_cpf' => \'IS NOT NULL',
			'me.serpro_tested'                       => 0
		},
		{
			for  => 'update',
			join => 'votolegal_donation_immutable'
		}
	);
}


sub run_once {
	my $self = shift;

	my $donation = $self->queue_rs->next;
	if ( ref $donation ) {
		return $self->exec_item($donation);
	}
	return 0;
}


sub exec_item {
	my ( $self, $donation ) = @_;

	$self->schema->txn_do(
		sub {
			$self->logger->info( "Processando a donation_id=" . $donation->id ) if $self->has_log;

			my $serpro_rs  = $self->schema->resultset("SerproResult");
			my $donor_cpf  = $donation->votolegal_donation_immutable->donor_cpf;
            my $donor_name = $donation->votolegal_donation_immutable->donor_name;

			return 1 if $serpro_rs->search( { donor_cpf => $donor_cpf } )->count > 0;

			my $serpro_res = $self->serpro->examine_cpf($donor_cpf);
			my $res_code   = $serpro_res->{situacao}->{codigo};
			my $res_name   = $serpro_res->{nome};

			my $is_dead_person = $res_code == 3 ? 1 : 0;

			my $consulted_cpf_entry = $self->schema->resultset("SerproResult")->create(
				{
					donor_cpf      => $donor_cpf,
					response       => encode_json $serpro_res,
					is_dead_person => $is_dead_person,
				}
			);

			$donation->update( { serpro_tested => 1 } );
		}
	);

	return 1;
}

sub _build_serpro { WebService::Serpro->new() }

__PACKAGE__->meta->make_immutable;

1;

