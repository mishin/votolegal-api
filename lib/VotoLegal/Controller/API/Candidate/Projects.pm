package VotoLegal::Controller::API::Candidate::Projects;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('projects') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->stash->{candidate}->projects;
}

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $id_project ) = @_;

    if ( my $project = $c->stash->{collection}->find($id_project) ) {
        $c->stash->{project} = $project;
    }
    else {
        $self->status_bad_request( $c, message => 'Project not found' );
        $c->detach();
    }
}

sub projects : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub projects_GET {
    my ( $self, $c ) = @_;

    my $page    = $c->req->params->{page}    || 1;
    my $results = $c->req->params->{results} || 20;

    return $self->status_ok(
        $c,
        entity => {
            projects => [
                map {
                    { $_->get_columns }
                  } $c->model('DB::ViewProjectValidVote')->search(
                    { candidate_id => $c->stash->{candidate}->id },
                    {
                        page     => $page,
                        rows     => $results,
                        order_by => "id",
                    }
                  )->all,
            ],
        }
    );
}

sub projects_POST {
    my ( $self, $c ) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    if ( $c->stash->{collection}->count >= 20 ) {
        die { error_code => 400, message => "Max projects limit reached", msg => "" };
    }

    my $project = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => $c->req->params,
    );

    $self->status_created(
        $c,
        location => $c->uri_for_action( $c->action, $c->req->captures, $project->id )->as_string,
        entity => { id => $project->id },
    );
}

sub project : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub project_GET {
    my ( $self, $c ) = @_;

    my $response = {
        ( map { $_ => $c->stash->{project}->$_ } qw(id title scope) ),
        votes =>
          $c->stash->{project}->project_votes->search( { 'donation.status' => "captured" }, { join => 'donation' }, )
          ->count,
    };

    return $self->status_ok( $c, entity => $response );
}

sub project_PUT {
    my ( $self, $c ) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    $c->stash->{project}->execute(
        $c,
        for  => "update",
        with => $c->req->params,
    );

    return $self->status_accepted( $c, entity => { id => $c->stash->{project}->id } );
}

sub project_DELETE {
    my ( $self, $c ) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    $c->stash->{project}->delete();

    return $self->status_no_content($c);
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
