use common::sense;
use FindBin qw($Bin);

use DateTime::Format::DateParse;
use Digest::SHA qw/ sha256_hex /;

BEGIN {
    use lib "$Bin/../lib";
    $ENV{LR_CODE_JSON_FILE} = $Bin . '/../../lr_code.json';
}

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Aprovando o candidato.
    ok( my $candidate = $schema->resultset('Candidate')->search( { 'me.id' => $candidate_id } )->next, 'get candidate' );
    ok( $candidate->update( { status => 'activated' } ), 'activate candidate' );

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
      name   => 'edit candidate',
      params => {
        cnpj               => format_cnpj( random_cnpj() ),
        payment_gateway_id => 2,
        merchant_id        => fake_email->(),
        merchant_key       => random_string(32),
      },
    ;

    # Mockando doações.
    for my $i (1 .. 5) {
        my $donation = &mock_donation;
        $donation->update(
            {
                captured_at         => \"(NOW() - (ROUND(RANDOM() * 1440) || ' minutes')::interval)",
                decred_merkle_root  => sha256_hex(int($i % 3)),
                decred_capture_txid => sha256_hex(random_string(10)),
                dcrtime_timestamp   => \"(NOW() - (ROUND(RANDOM() * 1440) || ' minutes')::interval)",
            }
        );
    }

    subtest 'list all' => sub {

        rest_get [ '/public-api/blockchain' ],
          name  => 'list',
          stash => 'blockchain_list',
        ;

        stash_test 'blockchain_list' => sub {
            my $res = shift;

            like( $res->[0]->{decred_merkle_root}, qr/^[a-f0-9]+$/i, 'decred merkle root' );
            is( ref $res->[0]->{donations}, 'ARRAY', 'donations=ARRAY' );
            ok( scalar(@{ $res->[0]->{donations} }) > 0, 'has donation' );
        };
    };

    rest_get [ '/public-api/blockchain/search/fvox' ],
      name    => 'search --invalid hash',
      is_fail => 1,
      code    => 400,
    ;

    subtest 'search by merkle root' => sub {

        my $list = stash 'blockchain_list';
        my $decred_merkle_root = fake_pick( map { $_->{decred_merkle_root} } @{ $list } )->();

        rest_get [ '/public-api/blockchain/search', $decred_merkle_root ],
          name  => 'search by valid block',
          stash => 'search_block',
        ;

        stash_test 'search_block' => sub {
            my $res = shift;

            like( $res->[0]->{decred_merkle_root}, qr/^[a-f0-9]+$/i, 'decred merkle root' );
            is( ref $res->[0]->{donations}, 'ARRAY', 'donations=ARRAY' );
            ok( scalar(@{ $res->[0]->{donations} }) > 0, 'has donation' );

            # Highlight.
            ok( grep { $_->{highlight} == 1 } map { map { $_ } @{ $_->{donations} } } grep { $_->{decred_merkle_root} eq $decred_merkle_root } @{ $res } );
            ok( grep { $_->{highlight} == 0 } map { map { $_ } @{ $_->{donations} } } grep { $_->{decred_merkle_root} ne $decred_merkle_root } @{ $res } );
        };
    };

    subtest 'search by digest' => sub {

        my $list = stash 'blockchain_list';
        my $digest = fake_pick( map { map { $_->{decred_data_digest} } @{ $_->{donations } } } @{ $list } )->();

        rest_get [ '/public-api/blockchain/search', $digest ],
          name  => 'search by digest',
          stash => 'search_digest',
        ;

        stash_test 'search_digest' => sub {
            my $res = shift;

            like( $res->[0]->{decred_merkle_root}, qr/^[a-f0-9]+$/i, 'decred merkle root' );
            is( ref $res->[0]->{donations}, 'ARRAY', 'donations=ARRAY' );
            ok( scalar(@{ $res->[0]->{donations} }) > 0, 'has donation' );

            # Highlight.
            ok( grep { $_->{decred_data_digest} eq $digest && $_->{highlight} == 1 } map { map { $_ } @{ $_->{donations} } } @{ $res } );
            ok( grep { $_->{decred_data_digest} ne $digest && $_->{highlight} == 0 } map { map { $_ } @{ $_->{donations} } } @{ $res } );
        };
    };

    subtest 'search by date' => sub {

        my $now = $schema->storage->dbh_do(sub {
            DateTime::Format::DateParse->parse_datetime($_[1]->selectrow_array('SELECT CURRENT_TIMESTAMP;'));
        });

        rest_get [ '/public-api/blockchain/search', $now->ymd() ],
          name  => 'search by date',
          stash => 'search_date',
        ;

        stash_test 'search_date' => sub {
            my $res = shift;

            like( $res->[0]->{decred_merkle_root}, qr/^[a-f0-9]+$/i, 'decred merkle root' );
            is( ref $res->[0]->{donations}, 'ARRAY', 'donations=ARRAY' );
            ok( scalar(@{ $res->[0]->{donations} }) > 0, 'has donation' );

            ok( grep { $_->{highlight} == 1 } map { map { $_ } @{ $_->{donations} } } @{ $res } );
        };
    };
};

done_testing();

sub mock_donation {
    api_auth_as 'nobody';

    generate_device_token;
    set_current_dev_auth( stash 'test_auth' );

    my $cpf = random_cpf();

    my $response = rest_post "/api2/donations",
      name   => "add donation",
      params => {
        generate_rand_donator_data_cc(),
        candidate_id                  => stash 'candidate.id',
        device_authorization_token_id => stash 'test_auth',
        payment_method                => 'credit_card',
        cpf                           => $cpf,
        amount                        => 3000,
      };

    setup_success_mock_iugu_direct_charge_cc;
    my $donation_id  = $response->{donation}{id};
    my $donation_url = "/api2/donations/" . $donation_id;

    $response = rest_post $donation_url,
      code   => 200,
      params => {
        device_authorization_token_id => stash 'test_auth',
        credit_card_token             => 'A5B22CECDA5C48C7A9A7027295BFBD95',
        cc_hash                       => '123456'
      };
    is( messages2str($response), 'msg_cc_authorized msg_cc_paid_message', 'msg de todos os passos' );

    ok( my $donation = $schema->resultset('VotolegalDonation')->find($donation_id), 'get donation' );

    return $donation;
}
