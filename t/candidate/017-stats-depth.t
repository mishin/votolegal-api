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

    # Uma doação entre R$ 100,00 e R$ 500,00.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 35000,
            created_at => "2016-10-01"
        }),
        'donate R$ 350,00',
    );

    # Uma doação entre R$ 500,00 e R$ 1.000,00.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 99900,
            created_at => "2016-10-01"
        }),
        'donate R$ 999,00',
    );

    # Uma doação entre R$ 1.000,00 e R$ 50.000,00.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 2500000,
            created_at => "2016-10-01"
        }),
        'donate R$ 25.000,00',
    );

    # Uma doação maior que R$ 50.000,00.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 5000100,
            created_at => "2016-10-01"
        }),
        'donate R$ 50.001,00',
    );

    # Uma doação cancelada.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 20000,
            created_at => "2016-10-01",
            status     => "canceled",
        }),
        'canceled donation',
    );

    # Uma doação entre R$ 50,00 e R$ 100,00.
    ok (
        $candidate->donations->create({
            %{ $fakeDonation->() },
            amount     => 7500,
            created_at => "2016-10-01",
        }),
        'donate R$ 75,00',
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
                { count => 5, month => 10, year => 2016, amount => "7642500" },
            ],
        );

        is ($res->{donors}, 9, 'total donors');
        is ($res->{total_amount}, 8646500, 'total amount');
        is ($res->{total_party_fund}, 1_000_000, 'total party fund');
        is ($res->{total_credit_card}, 7645500, 'total credit card');
        is ($res->{total_electronic_transfer}, 1000, 'total eletronic transfer');
        is ($res->{donations_up_to_hundred}, 5, 'donations up to hundred');
        is ($res->{donations_between_hundred_and_fivehundred}, 1, 'donations between hundred and five hundred');
        is ($res->{donations_between_fivehundred_and_thousand}, 1, 'donations between fivehundred and thousand');
        is ($res->{donations_between_thousand_and_fiftythousand}, 1, 'donations between thousand and fifty thousand');
        is ($res->{donations_greater_than_fiftythousand}, 1, 'donations greater than fifty thousand');
        is ($res->{candidates_allowed_transparency}, 1, 'candidates allowed transparency');
        is ($res->{donations_through_votolegal}, 8, 'donations through votolegal');
        is ($res->{donations_canceled}, 1, 'canceled donations');
        is ($res->{candidates_received_via_credit_card}, 1, 'candidates who received via credit card');
        is ($res->{donations_up_to_fifty_through_votolegal}, 3, 'donations up to fifty through votolegal');
        is ($res->{donations_between_fifty_and_hundred_through_votolegal}, 1, 'donations between fifty and hundred');
        is ($res->{donations_between_hundred_and_fourhundred_through_votolegal}, 1, 'donations between hundred and fourhundred');
        is ($res->{donations_between_fourhundred_and_thousand_through_votolegal}, 1, 'donations between four hundred and thousand');
    };
};

done_testing();

