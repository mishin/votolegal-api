package VotoLegal::SchemaConnected;
use common::sense;
use FindBin qw($RealBin);
use Config::General;

require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(get_schema);

sub get_schema {
    require VotoLegal::Schema;

    my $conf =
         eval { new Config::General("$RealBin/../../votolegal.conf") }
      || eval { new Config::General("$RealBin/../votolegal.conf") };
    my %config = $conf->getall;

    my $db_config = $config{model}->{DB}->{connect_info};
    if ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) {
        $db_config = $config{model}->{DB}->{connect_info_test};
    }

    return VotoLegal::Schema->connect($db_config);
}

1;
