package VotoLegal::Controller::API::Admin::Candidate::Status;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Admin::Candidate::Status - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/admin/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub activate : Chained('root') : PathPart('activate') : Args(0) : ActionClass('REST') { }

sub activate_PUT {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{candidate};
    my $status    = $candidate->status;

    if (!$candidate->ficha_limpa) {
        return $self->status_bad_request($c, message => 'Você não pode aprovar um candidato ficha suja.');
    }

    $candidate->update({
        status => "activated",
    });

    #$candidate->send_email_approval() if $status eq "pending";

    return $self->status_ok($c, entity => { id => $candidate->id });
}

sub deactivate : Chained('root') : PathPart('deactivate') : Args(0) : ActionClass('REST') { }

sub deactivate_PUT {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{candidate};
    my $status    = $candidate->status;

    $candidate->update({
        status => "deactivated",
    });

    #$candidate->send_email_disapproval() if $status eq "pending";

    return $self->status_ok($c, entity => { id => $candidate->id });
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
