package VotoLegal::Controller::API::Certiface::Token;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/certiface/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('token') : CaptureArgs(0) { }

__PACKAGE__->meta->make_immutable;

1;
