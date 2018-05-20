package VotoLegal;
use Moose;
use utf8;
use namespace::autoclean;
use VotoLegal::Utils qw/remote_notify/;
use Catalyst::Runtime 5.80;
use Data::Dumper qw/Dumper/;
use DateTime;
use Log::Log4perl qw(:easy);

BEGIN {
    use VotoLegal::SchemaConnected qw/load_envs_via_dbi get_connect_info/;
    load_envs_via_dbi();
}

use Catalyst qw/
  ConfigLoader
  Authentication
  Authorization::Roles
  I18N
  /;
extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name           => 'VotoLegal',
    encoding       => 'UTF-8',
    'Plugin::I18N' => {
        maketext_options => {
            Path   => __PACKAGE__->path_to('lib/VotoLegal/I18N'),
            Decode => 1,
        }
    },

    using_frontend_proxy => 1,

    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header                      => 0,
);

before 'setup_components' => sub {
    my $app = shift;

    $app->config->{'Model::DB'}{connect_info} = get_connect_info();
};

if ( $ENV{VOTOLEGAL_API_LOG_DIR} ) {
    if ( -d $ENV{VOTOLEGAL_API_LOG_DIR} ) {

        my $date = DateTime->now->ymd('-');

        $ENV{VOTOLEGAL_API_LOG_FILE} = $ENV{VOTOLEGAL_API_LOG_DIR} . "/api.$date.$$.log";
        print STDERR "Redirecting STDERR/STDOUT to $ENV{VOTOLEGAL_API_LOG_FILE}\n";
        close(STDERR);
        close(STDOUT);
        open( STDERR, '>>', $ENV{VOTOLEGAL_API_LOG_FILE} ) or die 'cannot redirect STDERR';
        open( STDOUT, '>>', $ENV{VOTOLEGAL_API_LOG_FILE} ) or die 'cannot redirect STDOUT';

    }
    else {
        print STDERR "VOTOLEGAL_API_LOG_DIR is not a dir";
    }
}

Log::Log4perl->easy_init(
    {
        level  => $DEBUG,
        layout => '[%P] %d %m%n',
        ( $ENV{VOTOLEGAL_API_LOG_FILE} ? ( file => '>>' . $ENV{VOTOLEGAL_API_LOG_FILE} ) : () ),
        'utf8' => 1
    }
);

__PACKAGE__->log( get_logger() );

__PACKAGE__->setup();

sub build_api_error {
    my ( $app, %args ) = @_;
    my $msg_id = $args{msg_id};

    $msg_id =~ s/[ -]/_/go;

    my $loc_msg = $app->loc($msg_id);

    if ( $loc_msg eq $msg_id && $msg_id =~ /_missing$/ ) {
        $msg_id =~ s/_missing/_invalid/;
        $loc_msg = $app->loc($msg_id);
    }

    if ( $loc_msg eq $msg_id ) {

        remote_notify(
            sprintf( "[Voto Legal] Faltando traducao para msg_id=$msg_id [hostname=%s] [%s]",
                    $app->req->uri->as_string
                  . ( $app->req->data   ? Dumper( $app->req->data )   : '' ) . " - "
                  . ( $app->req->params ? Dumper( $app->req->params ) : '' ) ),
            channel => '#api-error'
        );

    }

    if ( $loc_msg =~ /invalid/ ) {
        $loc_msg =~ s/_invalid/ com valor inválido/;
    }
    my %err = (
        msg_id  => $msg_id,
        message => $loc_msg
    );

    $err{form_field} = $args{form_field} if $args{form_field};
    $err{extra}      = $args{extra}      if exists $args{extra};
    $err{reason}     = $args{reason}     if exists $args{reason};

    return \%err;
}

1;
