#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../lib";

use Config::General;
use VotoLegal::Schema;

# Config.
my $config = new Config::General("$RealBin/../votolegal.conf");
$config = { $config->getall };

my $schema = VotoLegal::Schema->connect( $config->{model}->{DB}->{connect_info} );

my $total_amount_raised = $schema->resultset("Donation")->search(
    {
        status       => "captured",
        by_votolegal => "true",
    }
)->get_column("amount")->sum;

my $total_candidates = $schema->resultset("Candidate")->search(
    {
        status         => "activated",
        payment_status => "paid"
    }
)->count;

my $total_people_donated = $schema->resultset('Donation')->search(
    {
        status       => "captured",
        by_votolegal => "true",
    },
    { group_by => "cpf" },
)->count;

my $total_donations = $schema->resultset('Donation')->search(
    {
        status       => "captured",
        by_votolegal => "true"
    }
)->count;

my $post = sprintf( "Candidatos ativos na plataforma: %d\n", $total_candidates );
$post .= sprintf( "Total de dinheiro arrecadado: R\$ %.2f\n", $total_amount_raised / 100 );
$post .= sprintf( "Número de doações efetuadas: %d\n",     $total_donations );
$post .= sprintf( "Total de pessoas que doaram: %d",          $total_people_donated );

$schema->resultset('SlackQueue')->create(
    {
        channel => "votolegal-bot",
        message => $post,
    }
);

