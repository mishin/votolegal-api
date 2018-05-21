use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    rest_post '/api/contact',
      name   => "contact",
      stash  => 'email',
      code   => 200,
      params => {
        name         => fake_name()->(),
        phone        => fake_digits("## #####-####")->(),
        email        => fake_email()->(),
        message      => fake_sentences(3)->(),
        is_candidate => fake_int( 0, 1 )->(),
        type         => fake_sentences(1)->(),
      },
      ;

    my $email = stash 'email';
    ok( $schema->resultset('EmailQueue')->find( $email->{id} ), 'email queued' );
};

done_testing();

