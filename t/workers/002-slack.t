use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use POSIX qw(strftime);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    use_ok 'VotoLegal::Worker::Slack';

    my $worker = new_ok(
        'VotoLegal::Worker::Slack',
        [
            schema => $schema,
            config => get_config,
        ]
    );

    ok( $worker->does('VotoLegal::Worker'), 'VotoLegal::Worker::Slack does VotoLegal::Worker' );

    my $slack_rs = $schema->resultset('SlackQueue');

    ok(
        my $message = $slack_rs->create(
            {
                channel => "votolegal-test",
                message => "Now is " . strftime( "%d/%m/%Y %H:%M:%S", localtime ),
            }
        ),
        'append message',
    );

    ok( $worker->run_once( $message->id ), 'run once' );

    is( $slack_rs->count, 0, 'message out of queue' );
};

done_testing();

