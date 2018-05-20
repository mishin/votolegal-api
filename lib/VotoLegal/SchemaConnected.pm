package VotoLegal::SchemaConnected;
use strict;
use warnings;
use utf8;
use FindBin qw($RealBin);
use DBI;

#use VotoLegal::Utils;

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
our @EXPORT_OK = qw(load_envs_via_dbi);

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

my $env_loaded=0;
sub load_envs_via_dbi {
    my ($self) = @_;
    $env_loaded++;

    my $conf = get_connect_info;

    my $dbh = DBI->connect( $conf->{dsn} , $conf->{user}, $conf->{password}, {AutoCommit => 0});


    my $confs = $dbh->selectall_arrayref('select "name", "value" from config where valid_to = \'infinity\'' , { Slice => {} } );

    foreach my $kv ( @$confs ) {
        my ($k, $v) = ($kv->{name}, $kv->{value} );
        $ENV{$k} = $v;
    }
    $dbh->disconnect  or warn $dbh->errstr;

    undef $dbh;
}

sub get_schema {
    load_envs_via_dbi() unless $env_loaded;
    require VotoLegal::Schema;
    return VotoLegal::Schema->connect(get_connect_info());
}

1;
