package VotoLegal::Controller::API2::DeviceAuthentication;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with/;

BEGIN { extends 'VotoLegal::Controller::API2::Role::REST' }

sub base : Chained('/api2/base') : PathPart('device-authentication') : CaptureArgs(0) { }

sub gentoken : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

}

sub gentoken_POST {
    my ( $self, $c ) = @_;

    # TODO add rate limiting

    my $ua_str = $c->req->user_agent;
    die_with 'invalid-user-agent' if length $ua_str < 5 || length $ua_str > 2048;

    my $ua = $c->model('DB')->schema->resultset('DeviceAuthorizationUa')->find_or_create( { user_agent => $ua_str } );

    my $device_ip = $c->req->header('CF-Connecting-IP') || $c->req->address;

    my $token = $c->model('DB')->schema->resultset('DeviceAuthorizationToken')->create(
        {
            device_authorization_ua_id => $ua->id,

            # TODO add recaptcha
            verified => 1,

            device_ip  => $device_ip,
            created_at => \'now()'
        }
    );

    $self->status_ok( $c, entity => { device_authorization_token_id => $token->id } );
}

__PACKAGE__->meta->make_immutable;

1;
