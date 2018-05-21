package VotoLegal::Worker::Blockchain;
use strict;
use warnings;
use Moose;

with 'VotoLegal::Worker';

use WebService::Dcrtime;

has 'timer' => (
    is      => 'rw',
    default => 30*60, # 30 min.
);

has 'schema' => (
    is       => 'rw',
    required => 1,
);

has 'dcrtime' => (
    is   => 'rw',
    lazy => 1,
    builder => '_build_dcrtime',
);

sub listen_queue {
    my $self = shift;

    # TODO Uratar o refund.
    my $queue_rs = $self->queue_rs;
    while (my $donation = $queue_rs->next()) {
        $self->exec_item($donation);
    }
}

sub queue_rs {
    my $self = shift;

    return $self->schema->resultset('VotolegalDonation')->search(
        {
            '-or' => [
                'me.decred_merkle_root'  => undef,
                'me.decred_capture_txid' => undef,
            ],
        },
        { for => 'update' }
    );
}

sub run_once {
    my $self = shift;

    my $donation = $self->queue_rs->next;
    if (ref $donation) {
        return $self->exec_item($donation);
    }
    return 0;
}

sub exec_item {
    my ($self, $donation) = @_;

    $self->schema->txn_do(sub {
        my $decred_merkle_root  = $donation->get_column('decred_merkle_root');
        my $decred_capture_txid = $donation->get_column('decred_capture_txid');

        if (!defined($decred_merkle_root)) {
            # Timestamp.
            $donation->upsert_decred_data;
            my $decred_data_digest = $donation->get_column('decred_data_digest');

            if (!defined($decred_merkle_root)) {
                $self->dcrtime->timestamp(
                    id      => 'votolegal',
                    digests => [ $decred_data_digest ]
                );
            }

            # Verify.
            my $verify = $self->dcrtime->verify(
                id      => 'votolegal',
                digests => [ $decred_data_digest ]
            );

            my $merkleroot  = $verify->{digests}->[0]->{chaininformation}->{merkleroot};
            my $transaction = $verify->{digests}->[0]->{chaininformation}->{transaction};
            my $empty = '0' x 64;

            my %update_data;
            if ($merkleroot ne $empty) {
                $update_data{decred_merkle_root} = $merkleroot;
                $update_data{decred_merkle_registered_at} = \'NOW()';
            }

            if ($transaction ne $empty) {
                $update_data{decred_capture_txid} = $transaction;
                $update_data{decred_capture_registered_at} = \'NOW()';
            }

            if (%update_data) {
                $donation->update( \%update_data );
            }
        }
    });

    return 1;
}

sub _build_dcrtime { WebService::Dcrtime->new() }

__PACKAGE__->meta->make_immutable;

1;

