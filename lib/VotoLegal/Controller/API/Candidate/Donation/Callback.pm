package VotoLegal::Controller::API::Candidate::Donation::Callback;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::SmartContract;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

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
        my $status      = $notification->{status};

        if ($status == 3) {
            # Buscando o id da donation na database.
            if (my $donation = $c->model('DB::Donation')->search({ id => $donation_id })->next) {
                $donation->update({ status => "captured" });

                # Registrando a doação na blockchain.
                my $environment   = is_test() ? "testnet" : "mainnet";
                my $smartContract = VotoLegal::SmartContract->new(%{ $c->config->{ethereum}->{$environment} });

                my $res = $smartContract->addDonation($c->stash->{candidate}->cpf, $donation->id);

                if (my $transactionHash = $res->getTransactionHash()) {
                    $donation->update({ transaction_hash => $transactionHash });
                }
            }
        }
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
