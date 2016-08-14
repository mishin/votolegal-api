package VotoLegal::Controller::API::Candidate::Donation::Callback;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('callback') : CaptureArgs(0) { }

sub callback : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub callback_POST {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        notificationCode => {
            type     => "Str",
            required => 1,
        },
    );

    my $notificationCode = $c->req->params->{notificationCode};

    my $notification = $c->stash->{pagseguro}->notification($notificationCode);

    if (ref $notification) {
        my $donation_id = $notification->{reference};

        my $donation = $c->model('DB::Donation')->search({ id => $donation_id })->next;
        $donation->update({
            status => "captured",
        });
    }

    return $self->status_ok(
        $c,
        entity => { ok => 1 },
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
