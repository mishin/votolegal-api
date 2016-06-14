package VotoLegal::Controller::API::Candidate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Candidate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('candidate') : CaptureArgs(0) { }

sub base : Chained('/api/logged') : PathPart('candidate') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->user->candidates;
}

sub candidate : Chained('base') : PathPart('') : ActionClass('REST') { }

sub candidate_GET {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{collection}->search(
        {},
        {
            join         => 'party',
            '+select'    => ['party.name'],
            '+as'        => ['party_name'],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    )->single;

    return $self->status_ok($c, entity => {
        candidate => $candidate,
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
