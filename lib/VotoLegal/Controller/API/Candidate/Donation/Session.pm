package VotoLegal::Controller::API::Candidate::Donation::Session;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('session') : CaptureArgs(0) { }

sub session : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub session_GET {
    my ($self, $c) = @_;

    # Driver do PagSeguro.
    my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $c->stash->{candidate}->merchant_id,
        merchant_key => $c->stash->{candidate}->merchant_key,
        sandbox      => is_test(),
    );

    my $session_id = $pagseguro->createSession();

    return $self->status_ok(
        $c,
        entity => {
            id => $session_id,
        }
    );
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
