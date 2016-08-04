use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

db_transaction {
    # Não é possível adicionar candidato ficha suja.
    my $name     = fake_name()->();
    my $username = lc $name;
    $username    =~ s/\s+/_/g;

    rest_post '/api/register',
        name    => "candidato ficha suja",
        is_fail => 1,
        params  => {
            username             => $username,
            password             => "foobarquux1",
            name                 => fake_name()->(),
            popular_name         => fake_surname()->(),
            email                => fake_email()->(),
            cpf                  => random_cpf(),
            address_state        => 'São Paulo',
            address_city         => 'Iguape',
            address_zipcode      => '11920-000',
            address_street       => "Rua Tiradentes",
            address_house_number => fake_int(1, 3000)->(),
            office_id            => 2,
            party_id             => 5,
            reelection           => 1,
            ficha_limpa          => 0,
        },
    ;

    # Registrando candidato.
    create_candidate;

    stash_test 'candidate.get', sub {
        my ($me) = @_;

        ok($me->{candidate}->{id} > 0, 'candidate id');
        is($me->{candidate}->{status}, "pending", 'candidate status pending');
    };

};

done_testing();

