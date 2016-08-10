package VotoLegal::Controller::API::Candidate::Payment::Session;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/payment/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('session') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};
}

sub session : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub session_POST {
    my ($self, $c) = @_;

    my $session_id = $c->stash->{collection}->newSession();

    if (!$session_id) {
        $self->status_bad_request($c, message => 'Invalid gateway response');
        $c->detach();
    }

    return $self->status_ok($c, entity => { id => $session_id });
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
