package VotoLegal::Controller::API::Candidate::Payment::Boleto;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/payment/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('boleto') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};
}

sub boleto : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub boleto_GET {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        senderHash => {
            type     => "Str",
            required => 1,
        },
    );

    my $payment = $c->stash->{collection}->getBoleto(
        senderHash                => $c->req->params->{senderHash},
        notificationURL           => $c->uri_for($c->controller('API::Candidate::Payment::Callback')->action_for('callback'), [ $c->stash->{candidate}->id ]),
        reference                 => $c->stash->{candidate}->id,
        senderName                => $c->stash->{candidate}->name,
        senderCNPJ                => $c->stash->{candidate}->cnpj,
        #senderAreaCode            => $c->stash->{candidate}->,
        #senderPhone               => $c->stash->{candidate}->,
        senderEmail               => (is_test ? 'fvox@sandbox.pagseguro.com.br' : $c->stash->{candidate}->user->email),
        shippingAddressPostalCode => $c->stash->{candidate}->address_zipcode,
        shippingAddressCity       => $c->stash->{candidate}->address_city,
        shippingAddressState      => $c->stash->{candidate}->address_state_code,
        shippingAddressStreet     => $c->stash->{candidate}->address_street,
        shippingAddressNumber     => $c->stash->{candidate}->address_house_number,
        shippingAddressDistrict   => "Centro",
        senderAreaCode            => "11",
        senderPhone               => "1111111",
    );

    if (!$payment) {
        $self->status_bad_request($c, message => 'Invalid gateway response');
        $c->detach();
    }

    return $self->status_ok($c, entity => { url => $payment->boleto_url });
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
