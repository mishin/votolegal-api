use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    my $id_candidate  = stash 'candidate.id';
    ok (my $candidate = $schema->resultset('Candidate')->find($id_candidate));

    # Não pode gerar session de um candidato não aprovado.
    rest_post "/api/candidate/$id_candidate/payment/session",
        name    => "can't get session when not activated",
        is_fail => 1,
    ;

    $candidate->update({
        status => "activated",
        cnpj   => random_cnpj(),
    });

    # Gerando uma session.
    rest_post "/api/candidate/$id_candidate/payment/session",
        name  => "get session",
        stash => "s1",
        code  => 200,
    ;

    stash_test 's1' => sub {
        my $res = shift;

        is (length $res->{id}, 32, 'session id has 32 chars');
    };

    # Gerando o boleto.
    my $senderHash = "aca5f87211bba2a877dd837caaa09c5b06e118c4d29aefba11d61e6675597d0a";

    rest_get "/api/candidate/$id_candidate/payment/boleto",
        name    => "get boleto",
        stash   => "b1",
        params  => {
            senderHash => $senderHash,
        }
    ;

    my $boletoUrl ;
    stash_test 'b1' => sub {
        my $res = shift;

        ok ($boletoUrl = $res->{url}, 'boleto url');
    };

    # Chamando o callback como se o boleto tivesse sido pago.
    ok (my $payment = $schema->resultset('Payment')->search({ boleto_url => $boletoUrl })->next, 'payment');
    is ($payment->candidate_id, $id_candidate, 'candidate id');
};

done_testing();

