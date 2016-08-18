package VotoLegal::Controller::API::Candidate::Payment::Callback;
use common::sense;
use Moose;
use namespace::autoclean;

use Mojo::Cloudflare;
use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/payment/base') : PathPart('') : CaptureArgs(0) {
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

    my $notificationCode        = $c->req->params->{notificationCode};
    my $payment_notification_rs = $c->model('DB::PaymentNotification');

    # Buscando uma notificação com esse id.
    my $notify = $payment_notification_rs->search( { notification_code => $notificationCode, } )->next;

    # Se não encontrar, criamos esse registro no banco.
    if ( !$notify ) {
        $notify = $payment_notification_rs->create( { notification_code => $notificationCode, } );
    }

    if ( my $req = $c->stash->{pagseguro}->notification($notificationCode) ) {
        my $status = $req->{status};

        if ( $status == 3 ) {
            $c->stash->{candidate}->update( { payment_status => "paid" } );

            my $config = $c->config;
            if (!is_test() && $config->{cloudflare}->{enabled}) {
                eval {
                    my $cf = Mojo::Cloudflare->new(
                        email => $config->{cloudflare}->{username},
                        key   => $config->{cloudflare}->{apikey},
                        zone  => $config->{cloudflare}->{zoneurl}
                    );

                    my $domain = $config->{cloudflare}->{zoneurl};
                    my $test   = $cf->record(
                        {
                            content => $config->{cloudflare}->{dns_value},
                            name    => $c->stash->{candidate}->username . '.' . $config->{cloudflare}->{zoneurl},
                            type    => $config->{cloudflare}->{dns_type},
                        }
                    )->save;

                    $test->service_mode(1);
                    $test->save;
                };
                $c->log->error("Cloudflare error: $@");

            }
        }
    }

    return $self->status_ok( $c, entity => { success => 1 } );
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
