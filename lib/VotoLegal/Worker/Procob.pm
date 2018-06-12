package VotoLegal::Worker::Procob;
use strict;
use warnings;
use Moose;

with 'VotoLegal::Worker';

use WebService::Procob;

has 'timer' => (
	is      => 'rw',
	default => 30 * 60,    # 30 min.
);

has 'schema' => (
	is       => 'rw',
	required => 1,
);

has 'procob' => (
	is      => 'rw',
	lazy    => 1,
	builder => '_build_procob',
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

            my $donor_cpf = $donation->votolegal_donation_immutable->donor_cpf;

            my $procob_res = $self->procob->examine_cpf($donor_cpf);

            my $is_dead_person = $procob_res->{content}->{nome}->{conteudo}->{obito} eq 'SIM' ? 1 : 0;

            my $consulted_cpf_entry = $self->schema->resultset("ProcobResult")->create(
                {
                    donor_cpf      => $donor_cpf,
                    response       => $procob_res,
                    is_dead_person => $is_dead_person
                }
            );

            my $updated_balance = $self->schema->resultset("");
		}
	);

	return 1;
}

sub _build_procob { WebService::Procob->new() }

__PACKAGE__->meta->make_immutable;

1;

