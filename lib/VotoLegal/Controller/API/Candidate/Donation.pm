package VotoLegal::Controller::API::Candidate::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;
use VotoLegal::Types qw(CPF EmailAddress);
use VotoLegal::SmartContract;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $status         = $c->stash->{candidate}->status;
    my $payment_status = $c->stash->{candidate}->payment_status;

    if ( !$status eq "activated" || !$payment_status eq "paid" ) {
        $self->status_bad_request( $c, message => "candidato não aprovado." );
        $c->detach();
    }

    $c->stash->{collection} = $c->model('DB::Donation');
}

sub base : Chained('root') : PathPart('donate') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $donation_id ) = @_;

    $c->stash->{donation} = $c->stash->{collection}->search( { id => $donation_id } )->next;
}

sub donate : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub donate_GET {
    my ( $self, $c ) = @_;

    my $page    = $c->req->params->{page}    || 1;
    my $results = $c->req->params->{results} || 20;

    # O candidato vê apenas doações do VotoLegal.
    my @donations = $c->stash->{collection}->search(
        {
            candidate_id => $c->stash->{candidate}->id,

            # TODO reativar essa condicional após testes
            # status           => "captured",
            donation_type_id => 1,
            (
                $c->stash->{is_me} || !$c->stash->{candidate}->crawlable ? ( by_votolegal => "true" )
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
    if ( $c->stash->{is_me} ) {
        for my $donation (@donations) {
            my $payment_gateway_code = delete $donation->{payment_gateway_code};
            $payment_gateway_code =~ s/\-//g;

            my ( $docNumber, $authNumber ) = unpack( "(A16)*", $payment_gateway_code );
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

__PACKAGE__->meta->make_immutable;

1;
