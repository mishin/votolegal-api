package VotoLegal::Controller::API2::Donation;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with/;

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

    my $donation = $c->model('DB::VotolegalDonation')->execute(
        $c,
        for  => "create",
        with => $c->stash->{params}
    );

    $self->status_created(
        $c,
        location => $c->uri_for_action(
            $c->action, $c->req->captures,
            $donation->id, { device_authorization_token_id => $donation->device_authorization_token_id }
          )->as_string,

        entity => $donation->as_row()
    );
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

}

sub result_GET {
    my ( $self, $c ) = @_;

    $self->status_ok( $c, entity => $c->stash->{donation}->as_row() );
}

sub result_POST {
    my ( $self, $c ) = @_;

    $c->stash->{donation}->apply( $c->stash->{params} );

    $self->status_ok( $c, entity => $c->stash->{donation}->as_row() );
}

__PACKAGE__->meta->make_immutable;

1;
