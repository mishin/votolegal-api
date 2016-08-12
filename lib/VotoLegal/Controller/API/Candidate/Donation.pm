package VotoLegal::Controller::API::Candidate::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::SmartContract;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    if ($c->stash->{candidate}->status ne "activated") {
        $self->status_bad_request($c, message => "candidato não aprovado.");
        $c->detach();
    }

    for (qw(merchant_id merchant_key receipt_min receipt_max)) {
        defined $c->stash->{candidate}->$_ or die \[$_, "o candidato não configurou os dados do pagamento."];
    }
}

sub base : Chained('root') : PathPart('donate') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Donation');
}

sub donate : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub donate_GET {
    my ($self, $c) = @_;

    my $page    = $c->req->params->{page}    || 1;
    my $results = $c->req->params->{results} || 20;

    my @donations = $c->stash->{collection}->search(
        { candidate_id => $c->stash->{candidate}->id },
        {
            columns      => [ $c->stash->{is_me} ? qw(id name email cpf amount) : qw(id name amount) ],
            page         => $page,
            rows         => $results,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all;

    return $self->status_ok(
        $c,
        entity => {
            donations => \@donations,
        }
    );
}

sub donate_POST {
    my ($self, $c) = @_;

    my $donation ;

    $c->model('DB')->schema->txn_do(sub {
        # Lock.
        $c->model('DB::Candidate')->search(
            { id => $c->stash->{candidate}->id },
            { for => 'update', columns => 'id' }
        )->next;

        # Obtendo o id do recibo.
        my $receipt_min     = $c->stash->{candidate}->receipt_min;
        my $receipt_max     = $c->stash->{candidate}->receipt_max;
        my $last_receipt_id = $c->stash->{candidate}->donations->get_column("receipt_id")->max || $receipt_min;
        my $receipt_id      = $last_receipt_id + 1;

        # Verificando se o candidato possui recibos restantes disponíveis.
        if ($receipt_id > $receipt_max) {
            die \['receipt_max', "O candidato atingiu o número máximo de recibos emitidos."];
        }

        my $ipAddr = ($c->req->header("CF-Connecting-IP") || $c->req->header("X-Forwarded-For") || $c->req->address);

        $donation = $c->stash->{collection}->execute(
            $c,
            for  => "create",
            with => {
                %{ $c->req->params },
                candidate_id => $c->stash->{candidate}->id,
                receipt_id   => $receipt_id,
                ip_address   => $ipAddr,
                status       => "created",
            },
        );

        # Os dados do cartão *não* são salvos no banco de dados, então passo os parâmetros diretamente pra um atributo
        # da Model, armazenando assim apenas na RAM.
        $donation->credit_card_name($c->req->params->{credit_card_name});
        $donation->credit_card_validity($c->req->params->{credit_card_validity});
        $donation->credit_card_number($c->req->params->{credit_card_number});
        $donation->credit_card_brand($c->req->params->{credit_card_brand});

        my $tokenize ;
        eval {
            $tokenize = $donation->tokenize();
        };

        if (!$tokenize) {
            $self->status_bad_request($c, message => "não foi possível gerar o token do cartão.");
            $c->detach();
        }

        my $authorize ;
        my $capture ;
        eval {
            $authorize = $donation->authorize();
            $capture   = $donation->capture();
        };

        if (!$authorize || !$capture) {
            $self->status_bad_request($c, message => "transação não autorizada pelo gateway.");
            $c->detach();
        }
    });

    # Registrando a doação na blockchain.
    my $environment   = is_test() ? "testnet" : "mainnet";
    my $smartContract = VotoLegal::SmartContract->new(%{ $c->config->{ethereum}->{$environment} });

    my $res = $smartContract->addDonation($c->stash->{candidate}->id, $donation->id);

    if (my $transactionHash = $res->getTransactionHash()) {
        $donation->update({
            transaction_hash => $transactionHash,
        })
    }

    return $self->status_ok($c, entity => { id => $donation->id });
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
