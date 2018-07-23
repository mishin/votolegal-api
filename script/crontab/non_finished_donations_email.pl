#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../../lib";

use VotoLegal::SchemaConnected;

use JSON::XS;

my $schema = get_schema;

my @donations = $schema->resultset('ViewOpenDonationsWith3DayPeriod')->all();

for my $donation (@donations) {
	$schema->resultset('EmaildbQueue')->create(
		{
			config_id => 2,
			template  => 'non_finished_donation.html',
			to        => $donation->donor_email,
			subject   => 'Doe Marina - Termine sua doação',
			variables => encode_json( { donor_name => $donation->donor_name } ),
		}
	);
}