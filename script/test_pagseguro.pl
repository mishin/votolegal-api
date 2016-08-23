#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../lib";

use Config::General;
use VotoLegal::Utils;
use VotoLegal::Schema;
use VotoLegal::Payment::PagSeguro;

use Data::Printer;

# Config.
my $config = new Config::General("$RealBin/../votolegal.conf");
$config = { $config->getall };

# Schema.
my $schema = VotoLegal::Schema->connect($config->{model}->{DB}->{connect_info});

# Buscando candidatos ativos.
my $candidate_rs = $schema->resultset('Candidate')->search({
    status         => "activated",
    payment_status => "paid",
});

printf "%d candidatos encontrados.\n", $candidate_rs->count;

while (my $candidate = $candidate_rs->next()) {
    my $merchant_id  = $candidate->merchant_id;
    my $merchant_key = $candidate->merchant_key;

    if (!$merchant_id || !$merchant_key) {
        printf(
            "O candidato '%s' (id %d) não configurou os dados de pagamento corretamente. [merchant_id: '%s'] [merchant_key: '%s']\n",
            $candidate->name,
            $candidate->id,
            $merchant_id,
            $merchant_key,
        );
        next;
    }

    my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $merchant_id,
        merchant_key => $merchant_key,
        sandbox      => 0,
    );

    my $session = $pagseguro->createSession();

    if (!$session) {
        printf(
            "O candidato '%s' (id %d) não configurou os dados de pagamento corretamente. [merchant_id: '%s'] [merchant_key: '%s']\n",
            $candidate->name,
            $candidate->id,
            $merchant_id,
            $merchant_key,
        );
    }
}

