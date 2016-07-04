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
    my $forgot_password = $schema->resultset('UserForgotPassword')->search({
        user_id     => $candidate->user->id,
        valid_until => { '>=' => \'NOW()' },
    })->next;

    my $token = $forgot_password->token;
    is (length $token, 40, 'token has 40 chars');

    # O email foi pra queue?
    ok ($schema->resultset('EmailQueue')->count, 'email queued');

    # Resetando o password.
    my $new_password = random_string(8);

    # Não é possível utilizar um token expirado.
    $forgot_password->update({
        valid_until => \"(NOW() - '1 minutes'::interval)",
    });

    rest_post "/api/login/forgot_password/reset/$token",
        name    => "reset password with invalid token",
        is_fail => 1,
        code    => 400,
        params  => {
            new_password => $new_password,
        },
    ;

    # Agora volto o valor do valid_until e essa troca tem que funcionar.
    $forgot_password->update({
        valid_until => \"(NOW() + '1 days'::interval)",
    });

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

