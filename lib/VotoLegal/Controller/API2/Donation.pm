package VotoLegal::Controller::API2::Donation;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with is_test/;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub base : Chained('/api2/base') : PathPart('donations') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $uuid ) = @_;

    $c->stash->{params}{donation_id} = $uuid;

    $c->stash->{donation} = $c->model('DB::VotolegalDonation')->execute(
        $c,
        for  => "search",
        with => $c->stash->{params}
    );
}

sub donation : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

}

sub donation_POST {
    my ( $self, $c ) = @_;

    my $ua_str = $c->req->user_agent;
    die_with 'invalid-user-agent' if length $ua_str < 5 || length $ua_str > 2048;

    my $ua = $c->model('DB')->schema->resultset('DeviceAuthorizationUa')->find_or_create( { user_agent => $ua_str } );

    $c->stash->{params}{user_agent_id} = $ua->id;

    my $donation = $c->model('DB::VotolegalDonation')->execute(
        $c,
        for  => "create",
        with => $c->stash->{params}
    );

    my $interface = $c->model('DB')->resultset('FsmState')->interface(
        class => 'payment',
        loc   => sub {
            return is_test() ? join( '', @_ ) : $c->loc(@_);
        },
        donation => $donation,

        supports => $self->_supports($c),
    );

    $self->status_created(
        $c,
        entity   => $interface,
        location => $c->uri_for_action(
            $c->action, $c->req->captures,
            $donation->id, { device_authorization_token_id => $donation->device_authorization_token_id }
        )->as_string
    );
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

}

sub result_GET {
    my ( $self, $c ) = @_;

    my $interface = $c->model('DB')->resultset('FsmState')->interface(
        class => 'payment',
        loc   => sub {
            return is_test() ? join( '', @_ ) : $c->loc(@_);
        },
        donation => $c->stash->{donation},

        supports => $self->_supports($c),
    );

    $self->status_ok( $c, entity => $interface );

}

sub result_POST {
    my ( $self, $c ) = @_;

    my $interface = $c->model('DB')->resultset('FsmState')->apply_interface(
        class => 'payment',
        loc   => sub {
            return is_test() ? join( '', @_ ) : $c->loc(@_);
        },
        donation => $c->stash->{donation},
        params   => $c->stash->{params},

        supports => $self->_supports($c),

    );

    $self->status_ok( $c, entity => $interface );

}

# nao temos nada ainda pelo navegador..
sub _supports {
    {};
}

__PACKAGE__->meta->make_immutable;

1;
