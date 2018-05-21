use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

rest_get "/api/payment_gateway",
  name  => "payment gateways",
  stash => "p1",
  ;

stash_test 'p1' => sub {
    my $res = shift;

    is_deeply(
        $res->{payment_gateway},
        [
            {
                id   => 1,
                name => 'Cielo',
            },
            {
                id   => 2,
                name => 'PagSeguro',
            },
            {
                id   => 3,
                name => 'Iugu'
            }
        ],
        'payment gateway'
    );
};

done_testing();

