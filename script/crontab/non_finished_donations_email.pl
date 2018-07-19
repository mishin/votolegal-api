#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../../lib";

use VotoLegal::SchemaConnected;

my $schema = get_schema;

my $candidate_rs = $schema->resultset('Candidate')->search( { status => 'activated' } );
my $donation_rs  = $schema->resultset('VotolegalDonation');

my $candidate    = $candidate_rs->next();
my $candidate_id = $candidate->id;
my $count = 0;
while ( my $candidate = $candidate_rs->next() ) {
    my $candidate_id = $candidate->id;

    my $foo = $donation_rs->get_non_finished_donations_on_last_3_days($candidate_id);
    $count++;
}

use DDP; p $count;