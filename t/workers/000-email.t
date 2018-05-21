use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    use_ok 'VotoLegal::Worker::Email';

    my $worker = new_ok(
        'VotoLegal::Worker::Email',
        [
            schema => $schema,
            config => get_config,
        ]
    );

    ok( $worker->does('VotoLegal::Worker'), 'VotoLegal::Worker::Email does VotoLegal::Worker' );

    create_candidate;
    my $email_rs = $schema->resultset('EmailQueue');

    #is ($email_rs->count, 1, 'email is queued');

    my $email = $email_rs->next;
    ok( $worker->run_once( $email->id ), 'run once' );

    #is ($email_rs->count, 0, 'email out of queue');
};

done_testing();

