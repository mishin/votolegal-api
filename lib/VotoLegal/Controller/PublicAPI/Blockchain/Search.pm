package VotoLegal::Controller::PublicAPI::Blockchain::Search;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/publicapi/blockchain/base') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::VotolegalDonation')->search(
        {
            '-and' => [
                'me.refunded_at'         => \'IS NULL',
                'me.decred_merkle_root'  => \'IS NOT NULL',
            ],
        },
        {
            order_by => { '-desc ' => [ qw/ me.dcrtime_timestamp / ] },
            prefetch   => [ 'votolegal_donation_immutable', { candidate => 'party' }, { candidate => 'office' } ],
            '+columns' => [
                { captured_at_human      => \"TIMEZONE('America/Sao_Paulo', TIMEZONE('UTC', me.captured_at))" },
                { payment_method_human   => \"CASE WHEN me.is_boleto THEN 'Boleto' ELSE 'Cartão de crédito' END" },
                { decred_transaction_url => \"CASE WHEN me.decred_capture_txid IS NOT NULL THEN CONCAT('https://explorer.dcrdata.org/tx/', me.decred_capture_txid) END" },
                { git_url => \"CASE WHEN votolegal_donation_immutable.git_hash IS NOT NULL THEN CONCAT('https://github.com/AppCivico/votolegal-api/tree/', votolegal_donation_immutable.git_hash) END" },
            ],
        }
    );
}

sub base : Chained('root') : PathPart('search') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $param ) = @_;

    if ( $param =~ m{^[a-f0-9]{64}$}i ) {
        $c->stash->{search_term} = $param;
        $c->stash->{collection}  = $c->stash->{collection}->search(
            {
                '-and' => [
                    \[ <<'SQL_QUERY', $param, $param ],
                        DATE(me.dcrtime_timestamp) = (
                            SELECT DATE(MAX(vd.dcrtime_timestamp))
                            FROM votolegal_donation vd
                            WHERE vd.decred_data_digest = ?
                              OR vd.decred_merkle_root  = ?
                        )
SQL_QUERY
                ],
            },
            { '+columns' => [ { highlight => \[ "CASE WHEN me.decred_data_digest = ? OR me.decred_merkle_root = ? THEN True ELSE False END", $param, $param ] } ] },
        );
    }
    else {
        $self->status_bad_request( $c, message => 'Invalid sha256 hash.' );
        $c->detach();
    }
}

sub list : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    $c->forward('/publicapi/blockchain/list');
}

__PACKAGE__->meta->make_immutable;

1;
