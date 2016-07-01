use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

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

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            cielo_merchant_id  => "1006993069",
            cielo_merchant_key => "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3",
        },
    ;

    # Agora me deslogo de novo e realizo a doação.
    api_auth_as 'nobody';
    rest_post "/api/candidate/$candidate_id/donate",
        name    => "donate to candidate",
        code    => 200,
        params  => {
            name                 => fake_name()->(),
            cpf                  => random_cpf(),
            email                => fake_email()->(),
            credit_card_name     => "JUNIOR MORAES",
            credit_card_validity => "201801",
            credit_card_number   => "6362970000457013",
            credit_card_brand    => "elo",
            amount               => 100,
        },
    ;
};

done_testing();

