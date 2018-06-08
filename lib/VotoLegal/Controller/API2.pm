package VotoLegal::Controller::API2;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with is_test/;

BEGIN { extends 'VotoLegal::Controller::API2::Role::REST' }

sub base : Chained('/') : PathPart('api2') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $params = { %{ $c->req->data() && ref $c->req->data eq 'HASH' ? $c->req->data : {} }, %{ $c->req->params } };

    my $ipAddr = $c->req->header("CF-Connecting-IP") || $c->req->address;

    $params->{ip_address} = $ipAddr;

    $c->stash->{params} = $params;

    $c->response->headers->header( charset => "utf-8" );
}

sub recalc_summary : Chained('base') : PathPart('recalc_summary') : Args(0) {
    my ( $self, $c ) = @_;

    $c->res->body('disabled');

    $c->detach() unless ( $c->req->params->{secret} || '' ) eq $ENV{RECALC_SUMMARY_SECRET};

    $_->recalc_summary() for $c->model('DB::Candidate')->search(
        {
            payment_status => 'paid'
        }
    )->all;

    $c->res->body("updated");
}

sub sync_payments : Chained('base') : PathPart('sync_payments') : Args(0) {
    my ( $self, $c ) = @_;

    $c->res->body('disabled');

    $c->detach() unless ( $c->req->params->{secret} || '' ) eq $ENV{RECALC_SUMMARY_SECRET};

    $c->model('DB::VotolegalDonation')->sync_pending_payments(
        loc   => sub {
            return is_test() ? join( '', @_ ) : $c->loc(@_);
        },
    );

    $c->res->body("synced");
}
__PACKAGE__->meta->make_immutable;

1;
