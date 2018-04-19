package VotoLegal::Controller::API::Candidate::Payment::ProofOfLife;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/payment/base') : PathPart('') : CaptureArgs(0) {}

sub base : Chained('root') : PathPart('proof-of-life') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $token_uuid = $c->req->params->{token};
    die \['token', 'missing'] unless $token_uuid;



    return $self->status_ok($c, entity => { id => $session->{id} });
}

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
