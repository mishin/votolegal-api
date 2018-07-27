package VotoLegal::Controller::API2::Donation;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with is_test remote_notify/;

BEGIN { extends 'VotoLegal::Controller::API2::Role::REST' }

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

    my $interface = eval {
        $c->model('DB')->resultset('FsmState')->interface(
            class => 'payment',
            loc   => sub {
                return is_test() ? join( '', @_ ) : $c->loc(@_);
            },
            donation => $donation,

            supports => $self->_supports($c),
        );
    };
    if ( $@ && $@ =~ /payer.address.zip_code/ ) {
        remote_notify($@);

        die_with 'address_zip_code_error';
    }
    elsif ( $@ && $@ =~ /payer.address.number/ ) {
        remote_notify($@);

        die_with 'address_number_error';
    }
    elsif ($@) { die $@ }

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

    my $was_captured = $c->stash->{donation}->get_column('captured_at');

    my $interface = $c->model('DB')->resultset('FsmState')->interface(
        class => 'payment',
        loc   => sub {
            return is_test() ? join( '', @_ ) : $c->loc(@_);
        },
        donation => $c->stash->{donation},

        supports => $self->_supports($c),
    );

    $self->status_ok( $c, entity => $interface );

    $self->append_recalc($c) if $interface->{donation}{captured_at} && !$was_captured;
}

sub result_POST {
    my ( $self, $c ) = @_;

    my $was_captured = $c->stash->{donation}->get_column('captured_at');

    delete $c->stash->{params}{the_response};

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

    $self->append_recalc($c) if $interface->{donation}{captured_at} && !$was_captured;
}

sub append_recalc {
    my ( $self, $c ) = @_;

    my $candidate = $c->stash->{donation}->candidate;

    $c->run_after_request(
        sub {
            $candidate->recalc_summary();
            undef $candidate;
        }
    );
}

# nao temos nada ainda pelo navegador..
sub _supports {
    {};
}

__PACKAGE__->meta->make_immutable;

1;
