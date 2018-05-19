package VotoLegal;
use Moose;
use utf8;
use namespace::autoclean;
use VotoLegal::Utils qw/remote_notify/;
use Catalyst::Runtime 5.80;
use Data::Dumper qw/Dumper/;

use Catalyst qw/
  ConfigLoader
  Authentication
  Authorization::Roles
  I18N

  /;

BEGIN { $ENV{$_} or die "missing env '$_'." for qw/ RECAPTCHA_PUBKEY RECAPTCHA_PRIVKEY / }

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

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header                      => 0,    # Send X-Catalyst header

    recaptcha => {
        pub_key  => $ENV{RECAPTCHA_PUBKEY},
        priv_key => $ENV{RECAPTCHA_PRIVKEY},
    },
);

# Start the application
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
