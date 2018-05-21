package VotoLegal::Controller::API::IssuePriority;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::IssuePriority');
}

sub base : Chained('root') : PathPart('issue_priority') : CaptureArgs(0) { }

sub issue_priority : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub issue_priority_GET {
    my ( $self, $c ) = @_;

    return $self->status_ok(
        $c,
        entity => {
            issue_priority => [ map { { id => $_->id, name => $_->name } } $c->stash->{collection}->all() ]
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
