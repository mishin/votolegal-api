use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Geth;
use VotoLegal::Test::Further;

my $geth = VotoLegal::Geth->new();
if (!$geth->isTestnet()) {
    plan skip_all => "geth isn't running on testnet.";
}

my $schema = VotoLegal->model('DB');

db_transaction {
    use_ok 'VotoLegal::Worker::Blockchain';

    my $worker = new_ok('VotoLegal::Worker::Blockchain', [
        schema => $schema,
        config => get_config,
    ]);

    ok ($worker->does('VotoLegal::Worker'), 'does worker');

    # Criando um candidato que receberá as doações.
    create_candidate;

    # Não consigo testar doações na sandbox do gateway de pagamento (PagSeguro) pois o callback de aprovação
    # não chega. Dessa forma vou "mockar" uma doação diretamente na tabela donation com status de pago.
    my $donation_rs = $schema->resultset("Donation");

    my $receipt_id = fake_int(100, 1000)->();
    ok (
        my $donation = $schema->resultset("Donation")->create({
            id                           => md5_hex($receipt_id),
            candidate_id                 => stash 'candidate.id',
            name                         => fake_name()->(),
            email                        => fake_email()->(),
            cpf                          => random_cpf(),
            phone                        => fake_digits("##########")->(),
            amount                       => fake_int(1000, 10000)->(),
            birthdate                    => "1992-01-01",
            receipt_id                   => $receipt_id,
            ip_address                   => "127.0.0.1",
            address_state                => "SP",
            address_city                 => "Iguape",
            address_district             => "Centro",
            address_zipcode              => "11920-000",
            address_street               => "Rua Tiradentes",
            address_house_number         => 123,
            billing_address_street       => "Rua Tiradentes",
            billing_address_house_number => 123,
            billing_address_district     => "Centro",
            billing_address_zipcode      => "11920-000",
            billing_address_city         => "Iguape",
            billing_address_state        => "SP",
            status                       => "captured",
            captured_at                  => \'now()',
        }),
        "add donation",
    );

    ok ($worker->run_once(), 'run once');

    is (length($donation->discard_changes->transaction_hash), 66, 'transaction hash');
};

done_testing();

