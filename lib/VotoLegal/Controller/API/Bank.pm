package VotoLegal::Controller::API::Bank;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Office - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Bank');
}

sub base : Chained('root') : PathPart('bank') : CaptureArgs(0) { }

sub bank : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub bank_GET {
    my ($self, $c) = @_;

    return $self->status_ok($c, entity => {
        bank => [
            map { { id => $_->id, name => $_->name } }
              $c->stash->{collection}->all()
        ]
    });
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
