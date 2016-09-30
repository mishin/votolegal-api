use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Time::HiRes qw(time);
use Digest::MD5 qw(md5_hex);

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
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

    # Adicionando doações para o mês de julho.
    my $fakeDonation = fake_hash({
        id                 => sub { md5_hex(time) },
        cpf                => sub { random_cpf() },
        name               => fake_name(),
        email              => fake_email(),
        phone              => fake_digits("11#########"),
        amount             => "1000",
        status             => "captured",
        created_at         => \"now()",
        ip_address         => "127.0.0.1",
        by_votolegal       => "true",
        donation_type_id   => 1,
        payment_gateway_id => 1,
    });

    # Adicionando doações de variados meses.
    for my $created_at (qw(2016-05-01 2016-09-01 2015-02-01)) {
        ok (
            $candidate->donations->create({
                %{ $fakeDonation->() },
                created_at => $created_at,
            }),
            'add donation',
        );
    }

    # Uma doação do tipo fundo partidário.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount           => 1000000,
            by_votolegal     => "false",
            donation_type_id => 2,
        }),
        'donation from party fund',
    );

    # Uma doação via transferência eletronica.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            species          => "Transferência eletrônica",
            by_votolegal     => "false",
        }),
        'electronic transfer',
    );

    # Uma doação entre R$ 100 e R$ 500.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 35000,
            created_at => "2016-10-01"
        }),
        'donate R$ 350',
    );

    # Uma doação entre R$ 500 e R$ 1000.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 99900,
            created_at => "2016-10-01"
        }),
        'donate R$ 999',
    );

    # GET.
    rest_get "/api/stats/depth",
        name  => "depth stats",
        stash => "s1",
    ;

    stash_test "s1" => sub {
        my $res = shift;

        is_deeply(
            $res->{graph},
            [
                { count => 1, month => 2,  year => 2015, amount => "1000" },
                { count => 1, month => 5,  year => 2016, amount => "1000" },
                { count => 1, month => 9,  year => 2016, amount => "1000" },
                { count => 2, month => 10, year => 2016, amount => "134900" },
            ],
        );

        is ($res->{donors}, 6, 'total donors');
        is ($res->{total_amount}, 1138900, 'total amount');
        is ($res->{total_party_fund}, 1_000_000, 'total party fund');
        is ($res->{total_credit_card}, 5, 'total credit card');
        is ($res->{total_electronic_transfer}, 1000, 'total eletronic transfer');
        is ($res->{donations_between_hundred_and_fivehundred}, 1, 'donations between hundred and fivehundred');
        is ($res->{donations_between_fivehundred_and_thousand}, 1, 'donations between fivehundred and thousand');
    };
};

done_testing();

