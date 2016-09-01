use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    my $candidate    = $schema->resultset('Candidate')->find(stash 'candidate.id');
    my $id_candidate = stash 'candidate.id';

    # Adicionando duas despesas para calcular o valor total.
    my $cnpj = random_cnpj();
    my $name = fake_name()->();
    ok(
        $candidate->expenditures->create({
            name            => $name,
            cpf_cnpj        => $cnpj,
            date            => \"DATE(NOW())",
            amount          => 50000,
            type            => "Publicidade por adesivos",
            document_number => "SN",
            resource_specie => "Financeiro",
            document_specie => "Nota Fiscal",
        }),
        'add expenditure 1',
    );

    ok(
        $candidate->expenditures->create({
            name            => $name,
            cpf_cnpj        => $cnpj,
            date            => \"DATE(NOW())",
            amount          => 10000,
            type            => "Publicidade por adesivos",
            document_number => "SN",
            resource_specie => "Financeiro",
            document_specie => "Nota Fiscal",
        }),
        'add expenditure 2',
    );

    # Candidato desativado não pode ser visualizado.
    rest_get "/api/candidate/$id_candidate/expenditure",
        name    => "expenditure of deactivated candidate",
        is_fail => 1,
        code    => 400,
    ;

    # Ativando o candidato.
    $candidate->update({
        status         => "activated",
        payment_status => "paid",
    });

    # Listando as despesas.
    rest_get "/api/candidate/$id_candidate/expenditure",
        name    => "expenditure of deactivated candidate",
        stash   => 'e1',
    ;

    stash_test 'e1' => sub {
        my $res = shift;

        is ($res->{total_amount}, 60000, 'total amount');

        is_deeply(
            $res->{expenditure}->[0],
            {
                name     => $name,
                cpf_cnpj => $cnpj,
                amount   => 60000,
            },
            'get expenditures'
        );
    };
};

done_testing();

