use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    my $candidate = $schema->resultset('Candidate')->find(stash 'candidate.id');

    # Vou chamar o forgot_password três vezes. Teoricamente ele criou três tokens, mas esses três tokens não podem
    # ficar válidos simultaneamente por segurança.
    rest_post "/api/login/forgot_password",
        name   => "forgot password",
        code   => 200,
        params => {
            email => uc $candidate->user->email,
        },
    ;

    rest_post "/api/login/forgot_password",
        name   => "forgot password",
        code   => 200,
        params => {
            email => uc $candidate->user->email,
        },
    ;

    rest_post "/api/login/forgot_password",
        name   => "forgot password",
        code   => 200,
        params => {
            email => uc $candidate->user->email,
        },
    ;

    # Criei três tokens, mas apenas um deve ser válido.
    is (
        $schema->resultset('UserForgotPassword')->search({
            user_id => $candidate->user->id,
            valid_until => { '>=' => \'NOW()' },
        })->count,
        1,
        'only one token valid',
    );

    # O token retornado realmente pertence ao devido usuario?
    my $forgot_password = $schema->resultset('UserForgotPassword')->search({
        user_id     => $candidate->user->id,
        valid_until => { '>=' => \'NOW()' },
    })->next;

    my $token = $forgot_password->token;
    is (length $token, 40, 'token has 40 chars');

    # O email foi pra queue?
    is ($schema->resultset('EmailQueue')->count, 4, 'two emails in queue');

    # Resetando o password.
    my $new_password = random_string(8);

    # Não é possível utilizar um token expirado.
    $forgot_password->update({
        valid_until => \"(NOW() - '1 minutes'::interval)",
    });

    rest_post "/api/login/forgot_password/reset/$token",
        name    => "reset password with invalid token returns ok",
        code    => 200,
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
        code   => 200,
        params => {
            new_password => $new_password,
        },
    ;

    # O token deve ter expirado da tabela.
    ok (!defined($schema->resultset('UserForgotPassword')->search({ token => $token })->next), 'token expired');

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

