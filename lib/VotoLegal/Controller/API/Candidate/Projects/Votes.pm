package VotoLegal::Controller::API::Candidate::Projects::Votes;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/projects/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->stash->{project}->project_votes;
}

sub base : Chained('root') : PathPart('votes') : CaptureArgs(0) { }

sub votes : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub votes_POST {
    my ($self, $c) = @_;

    $c->model('DB::ProjectVote')->search({
        donation_id => $c->req->params->{donation_id}
    })->count >= 3 and die \['donation_id', "max vote limits reached."];

    my $vote = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

    return $self->status_ok($c, entity => { message => "ok" });
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
