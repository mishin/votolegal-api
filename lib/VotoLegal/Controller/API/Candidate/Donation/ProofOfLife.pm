package VotoLegal::Controller::API::Candidate::Donation::ProofOfLife;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use WebService::PagSeguro;

has _certiface => (
    is         => "ro",
    isa        => "WebService::Certiface",
    lazy_build => 1,
);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) {}

sub base : Chained('root') : PathPart('proof-of-life') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $token_uuid = $c->req->params->{token};
    die \['token', 'missing'] unless $token_uuid;

    my $sender_hash = $c->req->params->{sender_hash};
    die \['sender_hash', 'missing'] unless $sender_hash;

    my $token = $self->__certiface->get_token_information($token_uuid);

    my $pagseguro = WebService::PagSeguro->new(
        merchant_id  => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID},
        merchant_key => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY},
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => $ENV{VOTOLEGAL_PAGSEGURO_IS_SANDBOX},
        logger       => $c->log,
    );

    my $args = {
        method          => 'boleto',
        mode            => "default",
        currency        => 'BRL',
        extraAmount     => "0.00",
        items           => {
            id          => 1,
            description => 'Doação demonstrativa Voto Legal',
            amount      => '10.00',
            quantity    => 1
        },
        shipping        => {
            address => {
                country    => 'BRA',
                state      => 'São Paulo',
                postalCode => '04004-030',
                street     => 'Rua Desembargador Eliseu Guilherme',
                district   => 'Paraíso',
                number     => '53',
                complement => 'cj 21'
            }
        },
        sender          => {
            hash  => $sender_hash,
            name  => 'Thiago Rondon',
            phone => {
                areaCode => '11',
                number   => '33868181'
            },
            email => 'fvox@sandbox.pagseguro.com.br',
            documents => [
                {
                    document => {
                        type  => 'CPF',
                        value => '26241778846'
                    }
                }
            ]
        }
    };

    my $boleto = $pagseguro->transaction($args);

    return $self->status_ok(
        $c,
        entity => {
            url  => $boleto->{paymentLink},
        },
    );
}

sub _build__certiface { WebService::Certiface->instance }

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
