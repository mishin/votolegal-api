package VotoLegal::Controller::API::Candidate::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::SmartContract;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "Catalyst::TraitFor::Controller::reCAPTCHA";

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    my $status         = $c->stash->{candidate}->status;
    my $payment_status = $c->stash->{candidate}->payment_status;

    if (!$status eq "activated" || !$payment_status eq "paid") {
        $self->status_bad_request($c, message => "candidato não aprovado.");
        $c->detach();
    }

    for (qw(merchant_id merchant_key payment_gateway_id)) {
        defined $c->stash->{candidate}->$_ or die \[$_, "o candidato não configurou os dados do pagamento."];
    }
}

sub base : Chained('root') : PathPart('donate') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Donation');

    $c->stash->{pagseguro} = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $c->stash->{candidate}->merchant_id,
        merchant_key => $c->stash->{candidate}->merchant_key,
        sandbox      => is_test(),
        logger       => $c->log,
    );
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

    # Validando o captcha.
    #if (!is_test()) {
    #    if (!$c->forward("captcha_check")) {
    #        die \["captcha", "invalid"];
    #    }
    #}

    my $donation ;
    $c->model('DB')->schema->txn_do(sub {
        # Lock a fim de evitar duplicidade de recibos. Isso garante que não ocorrerá doações simultâneas para
        # um mesmo candidato.
        $c->model('DB::Candidate')->search(
            { id => $c->stash->{candidate}->id },
            { for => 'update', columns => 'id' },
        )->next;

        # Criando a donation.
        my $ipAddr = ($c->req->header("CF-Connecting-IP") || $c->req->header("X-Forwarded-For") || $c->req->address);

        my $environment = is_test() ? 'sandbox' : 'production';

        my $callback_url = $c->config->{pagseguro}->{$environment}->{callback_url};
        $callback_url   .= "/" unless $callback_url =~ m{\/$};
        $callback_url   .= "api/candidate/";
        $callback_url   .= $c->stash->{candidate}->id;
        $callback_url   .= "/donate/callback";

        $c->stash->{collection}->pagseguro($c->stash->{pagseguro});

        $donation = $c->stash->{collection}->execute(
            $c,
            for  => "create",
            with => {
                %{ $c->req->params },
                candidate_id     => $c->stash->{candidate}->id,
                ip_address       => $ipAddr,
                notification_url => $callback_url
            },
        );
    });

    if (!$donation) {
        $self->status_bad_request($c, message => 'Invalid gateway response');
        $c->detach();
    }

    $c->model('DB::SlackQueue')->create({
        channel => "votolegal-bot",
        message => sprintf(
            "%s efetuou uma doação de R\$ %.2f para o candidato %s.",
            $c->req->params->{name},
            $c->req->params->{amount} / 100,
            $c->stash->{candidate}->popular_name,
        ),
    });

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
