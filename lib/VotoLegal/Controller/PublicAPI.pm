package VotoLegal::Controller::PublicAPI;
use Moose;
use namespace::autoclean;

BEGIN { extends 'VotoLegal::Controller::API2::Role::REST' }

sub root : Chained('/') : PathPart('public-api') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $params = { %{ $c->req->data() && ref $c->req->data eq 'HASH' ? $c->req->data : {} }, %{ $c->req->params } };

    my $ipAddr = $c->req->header("CF-Connecting-IP") || $c->req->address;

    $params->{ip_address} = $ipAddr;

    $c->stash->{params} = $params;

    $c->response->headers->header( charset => "utf-8" );
}

1;
