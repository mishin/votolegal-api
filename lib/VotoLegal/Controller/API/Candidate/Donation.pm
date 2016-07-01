package VotoLegal::Controller::API::Candidate::Donation;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    if ($c->stash->{candidate}->status ne "activated") {
        $self->status_bad_request($c, message => "candidato não aprovado.");
        $c->detach();
    }

    for (qw(cielo_merchant_id cielo_merchant_key)) {
        $c->stash->{candidate}->$_ or die \[$_, "o candidato não configurou os dados do pagamento."];
    }
}

sub base : Chained('root') : PathPart('donate') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Donation');
}

sub donate : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub donate_POST {
    my ($self, $c) = @_;

    my $donation = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => {
            %{ $c->req->params },
            candidate_id => $c->stash->{candidate}->id,
            status       => "created",
        },
    );

    # Os dados do cartão *não* são salvos no banco de dados, então passo os parâmetros diretamente pra um atributo
    # da Model, armazenando assim apenas na RAM.
    $donation->credit_card_name($c->req->params->{credit_card_name});
    $donation->credit_card_validity($c->req->params->{credit_card_validity});
    $donation->credit_card_number($c->req->params->{credit_card_number});

    my $card_token ;
    if (!($card_token = $donation->tokenize())) {
        $self->status_bad_request($c, message => "não foi possível gerar o token do cartão.");
        $c->detach();
    }

    return $self->status_ok($c, entity => { });
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