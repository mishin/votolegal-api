use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    my $candidate = $schema->resultset('Candidate')->find(stash 'candidate.id');

    rest_post "/api/login/forgot_password",
        name   => "forgot password",
        stash  => "fp",
        code   => 200,
        params => {
            email => $candidate->user->email,
        },
    ;

    # O token retornado realmente pertence ao devido usuario?
    my $token ;
    stash_test 'fp' => sub {
        my ($res) = @_;

        $token = $res->{token};
        is (length $token, 40, 'token has 40 chars');

        is (
            $schema->resultset('UserForgotPassword')->search({ token => $token })->next->user_id,
            $candidate->user->id,
            'token belongs to user',
        );
    };

    # O email foi pra queue?
    ok ($schema->resultset('EmailQueue')->count, 'email queued');

    # Resetando o password.
    my $new_password = random_string(8);

    rest_post "/api/login/forgot_password/reset/$token",
        name   => "reset password",
        stash  => "rp",
        code   => 200,
        params => {
            new_password => $new_password,
        },
    ;

    # O token deve ter expirado da tabela.
    is ($schema->resultset('UserForgotPassword')->search({ token => $token })->count, 0, 'token expired');

    # Agora eu devo conseguir logar com a nova senha.
    rest_post '/api/login',
        name  => 'candidate login',
        code  => 200,
        stash => 'login',
        [
            email    => $candidate->user->email,
            password => $new_password,
        ],
    ;
};

done_testing();

