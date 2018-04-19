use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    my $cpf        = random_cpf();
    my $name       = fake_name()->();
    my $phone      = '(42)23423-4234';
    my $birthdate = '11/05/1998';

    # Aprovando o candidato.
    ok(
        $schema->resultset('Candidate')->find($candidate_id)->update({
            status         => "activated",
            payment_status => "paid",
        }),
        'activate',
    );

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
        name   => 'edit candidate',
        params => {
            payment_gateway_id => 2,
            merchant_id        => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID},
            merchant_key       => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY},
        },
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "Creating donation without method",
        is_fail => 1,
        code    => 400,
        [
            cpf        => $cpf,
            name       => $name,
            birthdate => $birthdate,
            phone      => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "Creating donation without cpf",
        is_fail => 1,
        code    => 400,
        [
            method     => 'boleto',
            name       => $name,
            birthdate => $birthdate,
            phone      => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "Creating donation without name",
        is_fail => 1,
        code    => 400,
        [
            method     => 'boleto',
            cpf        => $cpf,
            birthdate => $birthdate,
            phone      => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name    => "Creating donation without birth date",
        is_fail => 1,
        code    => 400,
        [
            method => 'boleto',
            cpf    => $cpf,
            name   => $name,
            phone  => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/donate",
        name                => "Creating donation",
        stash               => 'd1',
        code                => 200,
        automatic_load_item => 0,
        [
            method     => 'boleto',
            cpf        => $cpf,
            name       => $name,
            birthdate => $birthdate,
            phone      => $phone
        ]
    ;

    my $res = stash "d1";
};

done_testing();