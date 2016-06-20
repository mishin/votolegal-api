package VotoLegal::SchemaConnected;
use common::sense;
require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(get_schema);

sub get_schema {
    require VotoLegal::Schema;

    my $db_host = $ENV{VOTOLEGAL_DB_HOST} || 'localhost';
    my $db_pass = $ENV{VOTOLEGAL_DB_PASS} || 'no-password';
    my $db_port = $ENV{VOTOLEGAL_DB_PORT} || '5432';
    my $db_user = $ENV{VOTOLEGAL_DB_USER} || 'postgres';
    my $db_name = $ENV{VOTOLEGAL_DB_NAME} || 'votolegal_dev';

    VotoLegal::Schema->connect(
        "dbi:Pg:host=$db_host;port=$db_port;dbname=$db_name",
        $db_user, $db_pass,
        {
            "AutoCommit"     => 1,
            "quote_char"     => "\"",
            "name_sep"       => ".",
            "pg_enable_utf8" => 1,
            "on_connect_do"  => "SET client_encoding=UTF8"
        }
    );

}

1;
