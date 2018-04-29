package VotoLegal::Controller::API2;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub base : Chained('/') : PathPart('api2') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $params = { %{ $c->req->data() && ref $c->req->data eq 'HASH' ? $c->req->data : {} }, %{ $c->req->params } };

    my $ipAddr = $c->req->header("CF-Connecting-IP") || $c->req->address;

    $params->{ip_address} = $ipAddr;

    $c->stash->{params} = $params;

    $c->response->headers->header( charset => "utf-8" );
}

__PACKAGE__->meta->make_immutable;

1;
