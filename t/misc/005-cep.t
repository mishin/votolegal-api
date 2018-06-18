use Test::More;
use utf8;
use FindBin::libs qw( base=t subdir=lib );
use VotoLegal::Test::Further;
use Net::Ping;
my $p = Net::Ping->new("syn");

db_transaction {
    rest_get '/api/cep-states',
      name  => 'list states',
      stash => 'states';

    stash_test 'states', sub {
        my ($me) = @_;

        is( @{$me}, 27, '27 states' );

        rest_get [ '/api/cep-states', $me->[25]->{id} ],
          name  => 'list cities of sao-paulo',
          stash => 'cities_of_sp';

    };

    stash_test 'cities_of_sp', sub {
        my ($me) = @_;

        is( @{$me}, 939, '939 cities' );
    };

    if ( $p->ping( "8.8.8.8", 1 ) ) {

        my $info = rest_get ['/api/cep'],
          name   => 'get info about a cep',
          params => { cep => '04004030' };

        is_deeply(
            $info,
            {
                city     => "São Paulo",
                cep      => '04004030',
                district => "Paraíso",
                state    => "SP",
                street   => "Rua Desembargador Eliseu Guilherme"
            },
            'ok'
        );

		my $info_with_dismembered_cep = rest_get ['/api/cep'],
		  name    => 'get info about a dismembered cep',
		  params  => { cep => '50050020' },
          is_fail => 1,
          code    => 400;

		my $info_with_street_with_aditional_info = rest_get ['/api/cep'],
		  name    => 'get info about a dismembered cep',
		  params  => { cep => '05021001' },
		  code    => 200;
    }
    else {
        diag('no network, one test skiped');
    }

};

done_testing;