package VotoLegal::Controller::API::Candidate::Donation::Callback;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::SmartContract;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) {
}

sub base : Chained('root') : PathPart('callback') : CaptureArgs(0) {
}

sub callback : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') {
}

sub callback_POST {
    my ( $self, $c ) = @_;

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
        my $status      = $notification->{status};
        my $code        = $notification->{code};

        # Buscando o id da donation na database.
        if (my $donation = $c->model('DB::Donation')->search( { id => $donation_id } )->next) {
            if ($status == 3 || $status == 4) {
                $donation->update({
                    payment_gateway_code => $code,
                    status               => "captured",
                    (
                        defined($donation->captured_at)
                        ? ()
                        : ( captured_at => \"now()" )
                    ),
                });
            }
            elsif ($status == 6 || $status == 8) {
                $donation->update({
                    payment_gateway_code => $code,
                    status               => "chargeback",
                });
            }
        }
    }

    return $self->status_ok( $c, entity => { ok => 1 }, );
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
