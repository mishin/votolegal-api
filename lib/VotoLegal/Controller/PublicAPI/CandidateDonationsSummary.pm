package VotoLegal::Controller::PublicAPI::CandidateDonationsSummary;
use common::sense;
use Moose;
use namespace::autoclean;
use DateTime;
use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }


sub root : Chained('/publicapi/root') : PathPart('candidate-donations-summary') : CaptureArgs(0) {
	my ( $self, $c ) = @_;

	$c->stash->{collection} = $c->model('DB::Candidate')->search( { status => 'activated' } );
}

sub base : Chained('root') : PathPart('') : CaptureArgs(0) { }


sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
	my ( $self, $c, $args ) = @_;

	# Quando o parâmetro é inteiramente numérico, o buscamos como id.
	# Quando não é, pesquisamos pelo 'slug'.
	my $candidate;
	if ( $args =~ m{^[0-9]{1,6}$} ) {
		$candidate = $c->stash->{collection}->find($args);
	}else {
		$candidate = $c->stash->{collection}->search( { 'me.username' => $args } )->next;
	}

	if ( !$candidate ) {
		$self->status_not_found( $c, message => 'Candidate not found' );
		$c->detach();
	}

	$c->stash->{candidate} = $candidate;
}

sub donate : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }


sub donate_GET {
	my ( $self, $c ) = @_;

    my $candidate = $c->stash->{candidate};
    my $summary   = $candidate->candidate_donation_summary;

    my $raising_goal = $candidate->raising_goal;

	if ( $raising_goal ) {
		$raising_goal *= 100;
	}
    else {
		$raising_goal = 100000;
	}

    my $today_donations = $candidate->votolegal_donations->search(
        {
            created_at  => { '>=' => \'current_date::timestamp' },
            captured_at => { '!=' => undef },
            refunded_at => undef,
        },
        {
            columns => [
                { count_donated_by_votolegal => \'count(1)' },
                { total_donated_by_votolegal => \'sum( votolegal_donation_immutable.amount )' },
            ],
            join         => 'votolegal_donation_immutable',
            result_class => "DBIx::Class::ResultClass::HashRefInflator",

        }
    )->next;

	my $recent_donation = $candidate->votolegal_donations->search(
		{
            'me.refunded_at' => undef,
            'me.captured_at' => { '!=' => undef },
            'me.created_at'  => { '>=', \"(NOW() - '15 minutes'::interval)" },
		},
		{
	        join     => [ qw/ votolegal_donation_immutable / ],
            order_by => [ { '-desc' => "captured_at" }, { '-desc', 'me.created_at' } ],
            rows     => 1,
            columns => [
                { id          => 'me.id' },
                { captured_at => \"TIMEZONE('America/Sao_Paulo', TIMEZONE('UTC', me.captured_at))" },
                { amount      => 'votolegal_donation_immutable.amount' },
                { payment_method_human => \"CASE WHEN me.is_boleto THEN 'Boleto' ELSE 'Cartão de crédito' END" },
                { name        => 'votolegal_donation_immutable.donor_name' },
                { cpf         => 'votolegal_donation_immutable.donor_cpf' },
                { hash        => 'me.decred_capture_txid' },
                { digest      => 'me.decred_data_digest' },
                { transaction_link => \"case when me.decred_capture_txid is not null then concat('https://explorer.dcrdata.org/tx/', me.decred_capture_txid) end" },
            ],
		},
	)->next;

	return $self->status_ok(
		$c,
		entity => {
            candidate => {
				raising_goal               => $raising_goal,
				total_donated_by_votolegal => $summary->amount_donation_by_votolegal,
				count_donated_by_votolegal => $summary->count_donation_by_votolegal,
                generated_at               => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
            },
            today => {
				raising_goal               => $raising_goal,
				total_donated_by_votolegal => $today_donations->{total_donated_by_votolegal},
				count_donated_by_votolegal => $today_donations->{count_donated_by_votolegal}
            },
			recent_donor => (
				ref $recent_donation
				? (
					{
						map { $_ => $recent_donation->get_column($_) }
					  	qw /id captured_at refunded_at amount payment_method_human name cpf hash digest transaction_link /
					}
				)
				: undef
			),
		}
	);
}

__PACKAGE__->meta->make_immutable;

1;
