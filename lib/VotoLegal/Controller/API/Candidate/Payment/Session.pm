package VotoLegal::Controller::API::Candidate::Payment::Session;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/payment/base') : PathPart('') : CaptureArgs(0) {}

sub base : Chained('root') : PathPart('session') : CaptureArgs(0) { }

sub session : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub session_GET {
    my ($self, $c) = @_;

    my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID},
        merchant_key => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY},
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX},
        logger       => $c->log,
    );

    my $session = $pagseguro->createSession();

    if (!$session) {
        $self->status_bad_request($c, message => 'Invalid gateway response');
        $c->detach();
    }

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
