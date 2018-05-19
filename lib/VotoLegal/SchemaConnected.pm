package VotoLegal::SchemaConnected;
use strict;
use warnings;
use utf8;
use FindBin qw($RealBin);

use VotoLegal::Schema;
use VotoLegal::Utils;

BEGIN {
    $ENV{POSTGRESQL_HOST} ||= '127.0.0.1';
    $ENV{POSTGRESQL_PORT} ||= '5432';
    $ENV{POSTGRESQL_DBNAME} ||= 'votolegal_dev';
    $ENV{POSTGRESQL_USER} ||= 'postgres';
    $ENV{POSTGRESQL_PASSWORD} ||= 'trust';
};

require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(get_schema get_connect_info);

sub get_connect_info {
    my $host     = $ENV{POSTGRESQL_HOST};
    my $port     = $ENV{POSTGRESQL_PORT} || 5432;
    my $user     = $ENV{POSTGRESQL_USER};
    my $password = $ENV{POSTGRESQL_PASSWORD};
    my $dbname   = $ENV{POSTGRESQL_DBNAME};

    return {
        dsn            => "dbi:Pg:dbname=$dbname;host=$host;port=$port",
        user           => $user,
        password       => $password,
        AutoCommit     => 1,
        quote_char     => "\"",
        name_sep       => ".",
        auto_savepoint => 1,
        pg_enable_utf8 => 1,
    };
}

sub get_schema {
    return VotoLegal::Schema->connect(get_connect_info());
}

1;
