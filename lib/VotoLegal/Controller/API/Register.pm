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

sub register : Chained('/api/root') : PathPart('register') : ActionClass('REST') { }

sub register_POST {
    my ($self, $c) = @_;

    my $candidate_rs = $c->model('DB::Candidate');

    my $candidate = $c->model('DB::Candidate')->execute(
        $c,
        for => 'create',
        with => {
            %{ $c->req->params },
            status => "pending",
        },
    );

    $self->status_ok($c, entity => { candidate_id => $candidate->id });
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
