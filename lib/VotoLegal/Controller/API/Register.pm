package VotoLegal::Controller::API::Register;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

use DDP;

=head1 NAME

VotoLegal::Controller::API::Register - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate');
}

sub base : Chained('root') : PathPart('register') : CaptureArgs(0) { }

sub register : Chained('base') : PathPart('') : ActionClass('REST') { }

sub register_POST {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => {
            %{ $c->req->params },
            status => "pending",
        },
    );

    $candidate->send_email_registration();

    $self->status_created(
        $c,
        location => $c->uri_for($c->controller('API::Candidate')->action_for('candidate'), [ $candidate->id ]),
        entity   => { id => $candidate->id }
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
