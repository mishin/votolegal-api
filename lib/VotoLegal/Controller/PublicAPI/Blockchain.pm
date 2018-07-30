package VotoLegal::Controller::PublicAPI::Blockchain;
use common::sense;
use Moose;
use namespace::autoclean;

use List::Util 'reduce';

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/publicapi/root') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::VotolegalDonation')->search(
        {
            'me.refunded_at'         => \'IS NULL',
            'me.decred_merkle_root'  => \'IS NOT NULL',
        },
        {
            prefetch   => [ 'votolegal_donation_immutable', { candidate => 'party' }, { candidate => 'office' } ],
            '+columns' => [
                { captured_at_human => \"TIMEZONE('America/Sao_Paulo', TIMEZONE('UTC', me.captured_at))" },
                { payment_method_human => \"CASE WHEN me.is_boleto THEN 'Boleto' ELSE 'Cartão de crédito' END" },
                { decred_transaction_url => \"CASE WHEN me.decred_capture_txid IS NOT NULL THEN CONCAT('https://explorer.dcrdata.org/tx/', me.decred_capture_txid) END" },
                { git_url => \"CASE WHEN votolegal_donation_immutable.git_hash IS NOT NULL THEN CONCAT('https://github.com/AppCivico/votolegal-api/tree/', votolegal_donation_immutable.git_hash) END" },
            ],
        }
    );
}

sub base : Chained('root') : PathPart('blockchain') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->stash->{collection}->search(
        {
            '-and' => [
                \[ 'DATE(me.dcrtime_timestamp) = ( SELECT DATE(MAX(dcrtime_timestamp)) FROM votolegal_donation )' ],
            ],
        }
    );

    my @donations = $c->stash->{collection}->all();

    my $donations = reduce {
        my $donation = $b;
        my $donation_immutable = $donation->votolegal_donation_immutable;

        my $decred_merkle_root = $donation->get_column('decred_merkle_root');

        $a->{$decred_merkle_root}{donations} ||= [];

        push @{ $a->{$decred_merkle_root}{donations} }, {
            (
                map { $_ => $donation->get_column($_) }
                qw/ id candidate_id decred_capture_txid decred_data_raw decred_data_digest captured_at_human
                payment_method_human decred_transaction_url git_url /
            ),
            captured_at       => $donation->captured_at->datetime(),
            dcrtime_timestamp => $donation->dcrtime_timestamp->datetime(),
            (
                map { $_ => $donation_immutable->get_column($_) }
                qw/ donor_name donor_cpf git_hash amount /
            ),
            candidate => {
                (
                    map { $_ => $donation->candidate->get_column($_) }
                    qw/ id popular_name party_id cpf cnpj picture avatar color /
                ),
                party => {
                    map { $_ => $donation->candidate->party->get_column($_) }
                    qw/ id name acronym /
                },
                office => {
                    map { $_ => $donation->candidate->office->get_column($_) }
                    qw/ id name /
                },
            },
        };
        $a;
    } {}, @donations;

    return $self->status_ok(
        $c,
        entity => [
            map {
                my $decred_merkle_root = $_;

                +{
                    decred_merkle_root => $decred_merkle_root,
                    donations => $donations->{$decred_merkle_root}{donations},
                }
            } keys %{ $donations }
        ]
    );
}

__PACKAGE__->meta->make_immutable;

1;
