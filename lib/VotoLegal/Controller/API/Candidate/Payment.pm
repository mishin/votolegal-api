package VotoLegal::Controller::API::Candidate::Payment;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    die \['status', "not activated"]         unless $c->stash->{candidate}->status         eq "activated";
    die \['payment_status', "already paid."] unless $c->stash->{candidate}->payment_status eq "unpaid";

    my $environment = is_test() ? 'sandbox' : 'production';

    $c->stash->{pagseguro} = VotoLegal::Payment::PagSeguro->new(
        %{ $c->config->{pagseguro}->{$environment} },
        sandbox => is_test(),
    );
}

sub base : Chained('root') : PathPart('payment') : CaptureArgs(0) { }

sub payment : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub payment_POST {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        senderHash => {
            type     => "Str",
            required => 1,
        },
    );

    # Campos que são obrigatórios para gerar o boleto.
    my @required = qw(
        name cnpj phone address_zipcode address_city address_state address_street address_house_number
        address_district
    );

    for (@required) {
        if (!defined($c->stash->{candidate}->$_)) {
            die \[$_, "missing"];
        }
    }

    # Separando DDD e número do 'phone'.
    my $phone  = $c->stash->{candidate}->phone;
    my $ddd    = substr($phone, 0, 2);
    my $number = substr($phone, 2);

    my $zipcode = $c->stash->{candidate}->address_zipcode;
    $zipcode    =~ s/\D//g;

    my $cpf = $c->stash->{candidate}->cpf;
    $cpf    =~ s/\D//g;

    my $payment = $c->stash->{pagseguro}->transaction(
        paymentMethod             => "boleto",
        extraAmount               => "0.00",
        itemId1                   => "1",
        itemDescription1          => "Pagamento VotoLegal",
        itemAmount1               => "98.00",
        itemQuantity1             => "1",
        senderHash                => $c->req->params->{senderHash},
        reference                 => $c->stash->{candidate}->id,
        senderName                => $c->stash->{candidate}->name,
        senderCPF                 => $cpf,
        senderAreaCode            => $ddd,
        senderPhone               => $number,
        senderEmail               => (is_test() ? 'fvox@sandbox.pagseguro.com.br' : $c->stash->{candidate}->user->email),
        shippingAddressPostalCode => $zipcode,
        shippingAddressCity       => $c->stash->{candidate}->address_city,
        shippingAddressState      => $c->stash->{candidate}->address_state_code,
        shippingAddressStreet     => $c->stash->{candidate}->address_street,
        shippingAddressNumber     => $c->stash->{candidate}->address_house_number,
        shippingAddressDistrict   => $c->stash->{candidate}->address_district,
        notificationURL           => $c->uri_for(
            $c->controller('API::Candidate::Payment::Callback')->action_for('callback'),
            [ $c->stash->{candidate}->id ]
        )->as_string,
    );

    if (!$payment && !$payment->{paymentLink}) {
        $self->status_bad_request($c, message => 'Invalid gateway response');
        $c->detach();
    }

    $c->model('DB::Payment')->create({
        code         => $payment->{code},
        candidate_id => $c->stash->{candidate}->id,
        sender_hash  => $c->req->params->{senderHash},
        boleto_url   => $payment->{paymentLink},
    });

    return $self->status_ok(
        $c,
        entity   => { url => $payment->{paymentLink} },
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
