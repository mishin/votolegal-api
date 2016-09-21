use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Time::HiRes qw(time);
use Digest::MD5 qw(md5_hex);

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    # Adicionando dois candidatos. Apenas um será ativado.
    create_candidate for 1 .. 2;
    my $id_candidate = stash 'candidate.id';

    # Ativando o candidato.
    ok (my $candidate = $schema->resultset('Candidate')->find($id_candidate), 'select candidate');
    ok (
        $candidate->update({
            status         => "activated",
            payment_status => "paid",
        }),
        'activate candidate',
    );


    # Adicionando cinco doações, apenas as que foram realizadas pelo votolegal e possuem status 'captured' deverão
    # ser computadas.
    my $cpf = random_cpf();

    ok (
        $candidate->donations->create({
            id                 => md5_hex(time()),
            name               => fake_name()->(),
            email              => fake_email()->(),
            amount             => "50000",
            cpf                => $cpf,
            ip_address         => "127.0.0.1",
            species            => "Cartão de crédito",
            by_votolegal       => "true",
            status             => "captured",
            donation_type_id   => 1,
            payment_gateway_id => 1,
        }),
        'add donation 1',
    );

    ok (
        $candidate->donations->create({
            id                 => md5_hex(time()),
            name               => fake_name()->(),
            email              => fake_email()->(),
            amount             => fake_int(1000, 106400)->(),
            cpf                => random_cpf(),
            ip_address         => "127.0.0.1",
            species            => "Cartão de crédito",
            by_votolegal       => "true",
            status             => "chargeback",
            donation_type_id   => 1,
            payment_gateway_id => 2,
        }),
        'add donation 2',
    );

    ok (
        $candidate->donations->create({
            id                 => md5_hex(time()),
            name               => fake_name()->(),
            email              => fake_email()->(),
            amount             => "20000",
            cpf                => $cpf,
            ip_address         => "127.0.0.1",
            species            => "Cartão de crédito",
            by_votolegal       => "true",
            status             => "captured",
            donation_type_id   => 1,
            payment_gateway_id => 2,
        }),
        'add donation 3',
    );

    ok (
        $candidate->donations->create({
            id                 => md5_hex(time()),
            name               => fake_name()->(),
            email              => fake_email()->(),
            amount             => "1000",
            cpf                => random_cpf(),
            ip_address         => "127.0.0.1",
            species            => "Cartão de crédito",
            by_votolegal       => "false",
            status             => "captured",
            donation_type_id   => 1,
            payment_gateway_id => 2,
        }),
        'add donation 4',
    );

    ok (
        $candidate->donations->create({
            id                 => md5_hex(time()),
            name               => fake_name()->(),
            email              => fake_email()->(),
            amount             => "5000",
            cpf                => random_cpf(),
            ip_address         => "127.0.0.1",
            species            => "Cartão de crédito",
            by_votolegal       => "true",
            status             => "captured",
            donation_type_id   => 1,
            payment_gateway_id => 2,
        }),
        'add donation 5',
    );

    # Capturando as stats.
    rest_get "/api/stats",
        name  => 'get stats',
        stash => 's1',
    ;

    stash_test 's1' => sub {
        my $res = shift;

        # Total arrecadado.
        is ($res->{total_amount_raised}, 75000, 'total amount raised');

        # Total de pessoas que doaram.
        is ($res->{total_people_donated}, 2, "people donated");

        # Total de doações realizadas. Uma delas foi realizada com um mesmo CPF que outra.
        is ($res->{total_donations}, 3, "total donations");

        # Total de candidatos ativos na plataforma.
        is ($res->{candidates}, 1, "candidates activated");
    };
};

done_testing();

