package VotoLegal::Controller::API::Candidate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

use DDP;

=head1 NAME

VotoLegal::Controller::API::Candidate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('candidate') : CaptureArgs(1) {
    my ($self, $c, $username) = @_;

    my $user = $c->model('DB::User')->search({ username => $username })->single;

    if (!$user) {
        $self->status_bad_request($c, message => "Candidate not found");
        $c->detach();
    }

    $c->stash->{collection} = $user->candidates;
}

sub candidate : Chained('root') : PathPart('') : ActionClass('REST') { }

sub candidate_GET {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{collection}->search(
        {},
        {
            columns      => [ qw(id name popular_name ficha_limpa raising_goal reelection office_id) ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    )->single;

    if (!%{$candidate}) {
        $self->status_bad_request($c, message => 'Candidate not found');
        $c->detach();
    }

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
