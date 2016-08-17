use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Não pode doar pra candidato não aprovado.
    rest_post "/api/candidate/$candidate_id/donate",
        name    => "donate to candidate",
        is_fail => 1,
        params  => {
            name         => fake_name()->(),
            cpf          => random_cpf(),
            email        => fake_email()->(),
            amount       => 100,
        },
    ;

    # Aprovando o candidato.
    api_auth_as user_id => 1;
    rest_put "/api/admin/candidate/$candidate_id/activate",
        name  => 'activate candidate',
        code  => 200,
    ;

    # Não pode doar pra candidato que não tenha configurado os dados de pagamento.
    api_auth_as 'nobody';
    rest_post "/api/candidate/$candidate_id/donate",
        name    => "donate to candidate",
        is_fail => 1,
        params  => {
            name   => fake_name()->(),
            cpf    => random_cpf(),
            email  => fake_email()->(),
            amount => 100,
        },
    ;

    # Por enquanto não é possível escolher outro gateway de pagamento que não seja o PagSeguro.
    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name    => "other payment gateway",
        is_fail => 1,
        params  => {
            payment_gateway_id => 1,
        }
    ;

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            payment_gateway_id => 2,
            merchant_id        => VotoLegal->config->{pagseguro}->{sandbox}->{merchant_id},
            merchant_key       => VotoLegal->config->{pagseguro}->{sandbox}->{merchant_key},
            receipt_min        => 10_000,
            receipt_max        => 10_006,
        },
    ;

    # Listando as doações feitas para este candidato.
    api_auth_as candidate_id => stash 'candidate.id';
    rest_get "/api/candidate/$candidate_id/donate",
        name  => "listing donations",
        stash => "l1",
    ;

    stash_test 'l1' => sub {
        my ($res) = @_;

        is_deeply ($res->{donations}, [], 'no donations');
    };

    # Agora me deslogo de novo e realizo a doação.
    my $total_amount = 100;
    api_auth_as 'nobody';

    # Obtendo a sessão do PagSeguro.
    rest_get "/api/candidate/$candidate_id/donate/session",
        name  => "get session",
        stash => 's1',
    ;

    stash_test 's1' => sub {
        my $res = shift;
use DDP; p $res;
        ok ($res->{id} =~ m{^[a-f0-9]{32}$}, 'get session');
    };

    # Não consigo testar o pagseguro.
    done_testing(); exit 0;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "donate to candidate",
        stash   => 'd1',
        code    => 200,
        params  => {
            name                         => fake_name()->(),
            cpf                          => random_cpf(),
            email                        => fake_email()->(),
            phone                        => fake_digits("###########")->(),
            birthdate                    => "1992-05-02",
            address_street               => "Rua Tiradentes",
            address_house_number         => "123",
            address_district             => "Centro",
            address_zipcode              => "11920-000",
            address_city                 => "Iguape",
            address_state                => "SP",
            amount                       => 100,
            sender_hash                  => random_string(6),
            credit_card_token            => random_string(12),
            billing_address_street       => "Rua Tiradentes",
            billing_address_house_number => "123",
            billing_address_complement   => "Apto 1",
            billing_address_district     => "Centro",
            billing_address_zipcode      => "11920-000",
            billing_address_city         => "Iguape",
            billing_address_state        => "SP",
            credit_card_name             => "JUNIOR MORAES",
        },
    ;

    # O PagSeguro gera senderHash e credit_card_token no front-end, o que me impede de testar.
    done_testing; exit 0;

    my $donation_id ;
    stash_test 'd1' => sub {
        my $res = shift;

        ok ($donation_id = $res->{id}, 'has id');
    };

    # Depois de efetuar uma doação, vou listar novamente.
    api_auth_as candidate_id => stash 'candidate.id';
    rest_get "/api/candidate/$candidate_id/donate",
        name  => "listing donations",
        stash => "l2",
    ;

    stash_test "l2" => sub {
        my $res = shift;

        # A listagem só possui uma doação.
        is (scalar @{$res->{donations}}, 1, 'one donation');

        # O id da doação é o mesmo que recebi no POST.
        is ($res->{donations}->[0]->{id}, $donation_id, 'donation id');

        # Como estou logado como um candidato, devo ver dados como email e CPF.
        for (qw(name cpf email amount)) {
            ok (defined($res->{donations}->[0]->{$_}), "show '$_' logged as candidate");
        }
    };

    # Agora vou deslogar e fazer a mesma request para listar. Dados como CPF e email não devem aparecer.
    api_auth_as 'nobody';
    rest_get "/api/candidate/$candidate_id/donate",
        name  => "listing donations",
        stash => "l3",
    ;

    stash_test "l3" => sub {
        my $res = shift;

        ok (defined($res->{donations}->[0]->{$_}),  "show $_ when logged out") for qw(id amount name);
        ok (!defined($res->{donations}->[0]->{$_}), "hide $_ when logged out") for qw(cpf email);
    };

    # Fazendo mais cinco doações pra testar a paginação.
    for (1 .. 5) {
        my $amount = fake_pick(100, 500, 1000, 5000)->();
        $total_amount += $amount;

        rest_post "/api/candidate/$candidate_id/donate",
            name    => "donation $_",
            code    => 200,
            params  => {
                name                 => fake_name()->(),
                cpf                  => random_cpf(),
                email                => fake_email()->(),
                credit_card_name     => "JUNIOR MORAES",
                credit_card_validity => "201801",
                credit_card_number   => "6362970000457013",
                credit_card_brand    => "elo",
                amount               => $amount,
                birthdate            => "1992-05-02",
            },
        ;
    }

    # Listando as doações novamente, mas com parâmetros de paginação.
    rest_get "/api/candidate/$candidate_id/donate",
        name  => "listing donations",
        stash => "l4",
        params => {
            page    => 3,
            results => 2,
        },
    ;

    stash_test 'l4' => sub {
        my $res = shift;

        is (scalar @{ $res->{donations} }, 2, 'two results on pagination');
    };

    # Dando GET no candidate para testar o total doado.
    rest_get "/api/candidate/${candidate_id}",
        name  => 'get candidate',
        stash => 'g1',
    ;

    stash_test 'g1' => sub {
        my ($res) = @_;

        is(
            $res->{candidate}->{total_donated},
            $total_amount,
            'total donated'
        );
    };

    # Eu liberei apenas 7 recibos de doações. A próxima que eu fizer, deve estourar o limite.
    rest_post "/api/candidate/$candidate_id/donate",
        name    => "no receipts available",
        is_fail => 1,
        params  => {
            name                 => fake_name()->(),
            cpf                  => random_cpf(),
            email                => fake_email()->(),
            credit_card_name     => "JUNIOR MORAES",
            credit_card_validity => "201801",
            credit_card_number   => "6362970000457013",
            credit_card_brand    => "elo",
            amount               => "500",
            birthdate            => "1992-05-02",
        },
    ;
};

done_testing();

