use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

db_transaction {
    # Registrando candidato.
    create_candidate;

    stash_test 'candidate.get', sub {
        my ($me) = @_;

        ok($me->{candidate}->{id} > 0, 'candidate id');
        is($me->{candidate}->{status}, "pending", 'candidate status pending');
    };

    # Não pode registrar candidato sem sobrenome.
    my $username = lc(fake_name()->());
    $username    =~ s/\s+/_/g;

    rest_post '/api/register',
        name    => "candidato sem sobrenome",
        is_fail => 1,
        params  => {
            username             => $username,
            password             => "foobarquux1",
            name                 => "Junior",
            popular_name         => "Fvox",
            email                => fake_email()->(),
            cpf                  => random_cpf(),
            address_state        => 'SP',
            address_city         => 'Iguape',
            address_zipcode      => '11920-000',
            address_street       => "Rua Tiradentes",
            address_house_number => fake_int(1, 3000)->(),
            office_id            => 2,
            party_id             => 5,
            reelection           => 1,
        },
    ;

};

done_testing();

