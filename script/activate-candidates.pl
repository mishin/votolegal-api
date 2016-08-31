#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../lib";

use Config::General;
use Business::BR::CNPJ qw(test_cnpj);
use VotoLegal::Schema;

# Config.
my $config = new Config::General("$RealBin/../votolegal.conf");
$config = { $config->getall };

my $schema = VotoLegal::Schema->connect($config->{model}->{DB}->{connect_info});

my $candidate_rs = $schema->resultset('Candidate')->search({
    cnpj   => { '!=' => undef },
    cnpj   => { '!=' => "" },
    status => "pending",
});

while (my $candidate = $candidate_rs->next()) {
    if (test_cnpj($candidate->cnpj)) {
        $candidate->update({ status => "activated" });

        $schema->resultset('SlackQueue')->create({
            channel => "votolegal-bot",
            message => sprintf(
                "O candidato %s (%s) de CNPJ %s foi aprovado.",
                $candidate->name,
                $candidate->popular_name,
                $candidate->cnpj,
            ),
        });
    }
}

