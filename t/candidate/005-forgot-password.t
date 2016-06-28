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
    stash_test 'fp' => sub {
        my ($res) = @_;

        is (length $res->{token}, 40, 'token has 40 chars');

        is (
            $schema->resultset('UserForgotPassword')->search({ token => $res->{token} })->next->user_id,
            $candidate->user->id,
            'token belongs to user',
        );
    };

    # O email foi pra queue?
    ok ($schema->resultset('EmailQueue')->count, 'email queued');
};

done_testing();

