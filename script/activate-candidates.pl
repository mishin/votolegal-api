#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../lib";

use Business::BR::CNPJ qw(test_cnpj);
use VotoLegal::Schema;

use VotoLegal::SchemaConnected;

my $schema = get_schema;

my $candidate_rs = $schema->resultset('Candidate')->search(
    {
        cpf    => { '!=' => undef },
        cpf    => { '!=' => "" },
        status => "pending",
    }
);

while ( my $candidate = $candidate_rs->next() ) {
    $candidate->update( { status => "activated" } );
}

