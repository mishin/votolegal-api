package VotoLegal::Controller::API::Candidate::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Types qw(CPF EmailAddress);
use VotoLegal::SmartContract;
use WebService::Certiface;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

has _certiface => (
    is         => "ro",
    isa        => "WebService::Certiface",
    lazy_build => 1,
);

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    my $status         = $c->stash->{candidate}->status;
    my $payment_status = $c->stash->{candidate}->payment_status;

    if (!$status eq "activated" || !$payment_status eq "paid") {
        $self->status_bad_request($c, message => "candidato não aprovado.");
        $c->detach();
    }

    # for (qw(merchant_id merchant_key payment_gateway_id)) {
    #     defined $c->stash->{candidate}->$_ or die \[$_, "o candidato não configurou os dados do pagamento."];
    # }

    $c->stash->{collection} = $c->model('DB::Donation');
}

sub base : Chained('root') : PathPart('donate') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $donation_id) = @_;

    $c->stash->{donation} = $c->stash->{collection}->search({ id => $donation_id })->next;
}

sub donate : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub donate_GET {
    my ($self, $c) = @_;

    my $page    = $c->req->params->{page}    || 1;
    my $results = $c->req->params->{results} || 20;

    # O candidato vê apenas doações do VotoLegal.
    my @donations = $c->stash->{collection}->search(
        {
            candidate_id     => $c->stash->{candidate}->id,
            status           => "captured",
            donation_type_id => 1,
            (
                $c->stash->{is_me} || !$c->stash->{candidate}->crawlable
                ? ( by_votolegal => "true" )
                : ()
            ),
        },
        {
            columns => [
                $c->stash->{is_me}
                ? qw(name email cpf phone amount birthdate captured_at transaction_hash payment_gateway_code)
                : qw(name amount transaction_hash captured_at species)
            ],
            order_by     => { '-desc' => "captured_at" },
            page         => $page,
            rows         => $results,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all();

    # O 'Número do documento' e 'Número de autorização' é composto pelo payment_gateway_code splitado em duas partes.
    if ($c->stash->{is_me}) {
        for my $donation (@donations) {
            my $payment_gateway_code = delete $donation->{payment_gateway_code};
            $payment_gateway_code    =~ s/\-//g;

            my ($docNumber, $authNumber)      = unpack("(A16)*", $payment_gateway_code);
            $donation->{document_number}      = $docNumber;
            $donation->{authorization_number} = $authNumber;
        }
    }

    return $self->status_ok(
        $c,
        entity => {
            donations => \@donations,
        }
    );
}

sub donate_POST {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        method => {
            required => 1,
            type     => "Str",
        },
        name => {
            required => 1,
            type     => "Str"
        },
        cpf => {
            required => 1,
            type     => "Str",
        },
        phone => {
            required => 1,
            type     => "Str",
        },
        birthdate => {
            required => 1,
            type     => "Str",
        },
    );

    my $method = delete $c->req->params->{method};

    my $certiface_token_and_url;

    $c->req->params->{phone} =~ s/\D+//g;

    if ($method eq 'boleto') {
        # Gerando token do Certiface
        # para prova de vida
        my $opts = {
            cpf        => $c->req->params->{cpf},
            nome       => $c->req->params->{name},
            nascimento => $c->req->params->{birthdate},
            telefone   => $c->req->params->{phone}
        };

        my $certiface_token_rs      = $c->model("DB::CertifaceToken");
        $certiface_token_and_url    = $self->_certiface->generate_token( $opts );

        $certiface_token_rs->create( { uuid => $certiface_token_and_url->{uuid} } );
    }

    my $ipAddr = ($c->req->header("CF-Connecting-IP") || $c->req->header("X-Forwarded-For") || $c->req->address);

    my $donation = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => {
            %{ $c->req->params },
            candidate_id       => $c->stash->{candidate}->id,
            ip_address         => $ipAddr,
            certiface_token_id => $certiface_token_and_url->{uuid},
            payment_gateway_id => 3,
        },
    );

    if ($method eq 'credit_card') {
        $donation->logger($c->log);
        $donation->credit_card_token( $c->req->params->{credit_card_token} );

        my $authorize = $donation->authorize();
        my $capture   = $donation->capture();

        if (!$authorize || !$capture) {
            $self->status_bad_request($c, message => "Invalid gateway response.");
            $c->detach();
        }
    }

    my $ret;
    if ( $method eq 'boleto' ) {
        # No caso do boleto antes de ocorrer a doação deve ser feita a verificação do Certiface
        $ret = { %{$certiface_token_and_url} };
    }
    else {
        $ret = {
            id     => $donation->id,
            status => $donation->status,
        }
    }

    return $self->status_ok(
        $c,
        entity => $ret
    );
}

sub deactivated_donate_POST {
    my ($self, $c) = @_;

    my $payment_gateway_id = $c->stash->{candidate}->payment_gateway_id;

    if ($payment_gateway_id == 1) {
        # Cielo.
        $self->validate_request_params(
            $c,
            credit_card_name => {
                required => 1,
                type     => "Str",
            },
            credit_card_validity => {
                required => 1,
                type     => "Str",
            },
            credit_card_number => {
                required => 1,
                type     => "Str",
            },
            credit_card_brand => {
                required => 1,
                type     => "Str",
            },
            credit_card_cvv => {
                required => 1,
                type     => "Str",
            },
        );
    }
    elsif ($payment_gateway_id == 2) {
        # PagSeguro.
        $self->validate_request_params(
            $c,
            credit_card_name => {
                required => 1,
                type     => "Str",
            },
            sender_hash => {
                required => 1,
                type     => "Str",
            },
            credit_card_token => {
                required => 1,
                type     => "Str",
            },
        );
    }
    else {
        die \["payment_gateway_id", "invalid"];
    }

    my $ipAddr = ($c->req->header("CF-Connecting-IP") || $c->req->header("X-Forwarded-For") || $c->req->address);

    my $donation = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => {
            %{ $c->req->params },
            candidate_id       => $c->stash->{candidate}->id,
            ip_address         => $ipAddr,
            payment_gateway_id => $payment_gateway_id,
        },
    );

    # Os dados do cartão *não* são salvos no banco de dados, então passo os parâmetros diretamente pra um atributo
    # da Model, armazenando assim apenas na RAM.
    $donation->logger($c->log);
    $donation->credit_card_name($c->req->params->{credit_card_name});

    if ($payment_gateway_id == 1) {
        $donation->credit_card_validity($c->req->params->{credit_card_validity});
        $donation->credit_card_number($c->req->params->{credit_card_number});
        $donation->credit_card_brand($c->req->params->{credit_card_brand});
        $donation->credit_card_cvv($c->req->params->{credit_card_cvv});
    }
    elsif ($payment_gateway_id == 2) {
        my $environment = is_test() ? 'sandbox' : 'production';
        my $callback_url = $c->config->{pagseguro}->{$environment}->{callback_url};
        $callback_url   .= "/" unless $callback_url =~ m{\/$};
        $callback_url   .= "api/candidate/";
        $callback_url   .= $c->stash->{candidate}->id;
        $callback_url   .= "/donate/callback";

        $donation->notification_url($callback_url);
        $donation->sender_hash($c->req->params->{sender_hash});
        $donation->credit_card_token($c->req->params->{credit_card_token});
    }

    my $tokenize = $donation->tokenize();
    if (!$tokenize) {
        $self->status_bad_request($c, message => "Invalid gateway response.");
        $c->detach();
    }

    my $authorize = $donation->authorize();
    my $capture   = $donation->capture();

    if (!$authorize || !$capture) {
        $self->status_bad_request($c, message => "Invalid gateway response.");
        $c->detach();
    }

    # Enviando a notificação pro Slack.
    if (!is_test()) {
        $c->model('DB::SlackQueue')->create({
            channel => "votolegal-bot",
            message => sprintf(
                "%s efetuou uma doação de R\$ %.2f para o candidato %s.",
                $c->req->params->{name},
                $c->req->params->{amount} / 100,
                $c->stash->{candidate}->popular_name,
            ),
        });
    }

    return $self->status_ok($c, entity => { id => $donation->id });
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
