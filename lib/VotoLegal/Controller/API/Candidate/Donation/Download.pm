package VotoLegal::Controller::API::Candidate::Donation::Download;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends "CatalystX::Eta::Controller::REST" }

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('download') : CaptureArgs(0) { }

sub download : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub download_GET {
    my ($self, $c) = @_;

    if (my $hours = $c->req->params->{hours}) {

    }

    $c->stash->{collection} = $c->stash->{collection}->search({
        created_at => { '>=', \"(now() - '3 hours'::interval)" }
    });

    return $self->status_ok(
        $c,
        entity => {},
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
