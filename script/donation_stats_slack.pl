#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../lib";

use Config::General;
use WebService::Slack::IncomingWebHook;
use VotoLegal::Schema;

# Config.
my $config = new Config::General("$RealBin/../votolegal.conf");
$config = { $config->getall };

my $schema = VotoLegal::Schema->connect($config->{model}->{DB}->{connect_info});

my $donation_rs = $schema->resultset('Donation')->search(
    {
        "me.status"       => "captured",
        "me.by_votolegal" => 't',
    },
    {
        join     => "candidate",
        select   => [ "candidate.name", { sum => "amount", '-as' => "total_amount" } ],
        as       => [ qw(candidate_name total_amount) ],
        group_by => [ "candidate_id", "candidate.name" ],
        order_by => { '-desc' => "total_amount" },
        rows     => 20,
    },
);

my $post = "Os 20 candidatos que mais receberam doações:\n\n";

for my $donation (reverse $donation_rs->all()) {
    $post .= $donation->get_column('candidate_name');
    $post .= ": R\$ ";
    $post .= sprintf("%.2f", ($donation->get_column("total_amount") / 100));
    $post .= "\n";
}

$schema->resultset('SlackQueue')->create({
    channel => "votolegal-bot",
    message => $post,
});

