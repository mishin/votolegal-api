#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../lib";

use VotoLegal::SchemaConnected;
use VotoLegal::Worker::Email;

# Config.
my $config = new Config::General("$RealBin/../votolegal.conf");
$config = { $config->getall };

die "missing cloudflare conf\n" unless $config->{cloudflare};

use Mojo::Cloudflare;
my $cf = Mojo::Cloudflare->new(
    email => $config->{cloudflare}{username},
    key   => $config->{cloudflare}{apikey},
    zone  => $config->{cloudflare}{zoneurl}
);

my $domain    = $config->{cloudflare}{zoneurl};
my $domain_qr = quotemeta $domain;

my $exists = {};

# retrieve and update records
for my $record ( $cf->records->all ) {

    next if $record->name eq $config->{cloudflare}{zoneurl};
    next unless $record->type =~ /A|CNAME/i;
    next if $record->name =~ /^(www(\d+)?|ftp|email|.?api|.*badges.*)\.$domain_qr/i;

    my ($sub) = $record->name =~ /(.+)\.$domain_qr/;

    $exists->{$sub}++;

    # se n esta 'ligado', liga o proxy da cloudflare
    if ( !$record->service_mode() ) {
        $record->service_mode(1);
        $record->save;
    }
}

my $schema = get_schema;

my @domains =
  $schema->resultset('Candidate')->search( { username => { 'not in' => [ keys %$exists ] }, payment_status => 'paid' } )
  ->all;

foreach my $r (@domains) {
    my $test = $cf->record(
        {
            content => $config->{cloudflare}{dns_value},
            name    => $r->username . '.' . $config->{cloudflare}{zoneurl},
            type    => $config->{cloudflare}{dns_type},
        }
    )->save;

    $test->service_mode(1);
    $test->save;

}

