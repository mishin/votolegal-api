package VotoLegal::Controller::API::Candidate::Publish;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};
}

sub base : Chained('root') : PathPart('') : CaptureArgs(0) { }

sub publish : Chained('base') : PathPart('publish') : Args(0) : ActionClass('REST') { }

sub publish_POST {
    my ( $self, $c ) = @_;

    $c->stash->{candidate}->execute( $c, for => "publish", with => {} );

    return $self->status_ok( $c, entity => { id => $c->stash->{candidate}->id } );
}

sub unpublish : Chained('base') : PathPart('unpublish') : Args(0) : ActionClass('REST') { }

sub unpublish_POST {
    my ( $self, $c ) = @_;

    $c->stash->{candidate}->execute( $c, for => "unpublish", with => {} );

    return $self->status_ok( $c, entity => { id => $c->stash->{candidate}->id } );
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
