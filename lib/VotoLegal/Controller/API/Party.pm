package VotoLegal::Controller::API::Party;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Party - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('party') : CaptureArgs(0) { }

sub party : Chained('root') : PathPart('') ActionClass('REST') { }

sub party_GET {
    my ($self, $c) = @_;

    my @parties = map {
        {
            id   => $_->id,
            name => $_->name 
        }
    } $c->model('DB::Party')->all;

    return $self->status_ok($c, entity => { parties => \@parties });
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
