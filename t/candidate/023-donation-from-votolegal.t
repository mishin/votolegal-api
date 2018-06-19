use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Digest::MD5 qw(md5_hex);
use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

my $candidate;
my $candidate_id;

db_transaction {

    $candidate    = create_candidate;
    $candidate_id = $candidate->{id};

    # Aprovando o candidato.
    ok(
        $schema->resultset('Candidate')->find($candidate_id)->update(
            {
                status         => "activated",
                payment_status => "paid",
            }
        ),
        'activate',
    );

    api_auth_as candidate_id => $candidate_id;
    rest_put "/api/candidate/${candidate_id}",
      name   => 'edit candidate',
      params => {
        payment_gateway_id => 1,
        merchant_id        => fake_email->(),
        merchant_key       => random_string(32),
      },
      ;

    my $donation = &mock_donation;

    rest_get "/api/candidate/$candidate_id/votolegal-donations",
        name  => 'get donations from voto legal',
        list  => 1,
        stash => 'get_donations'
    ;

    stash_test 'get_donations' => sub {
        my $res = shift;

        is ( $res->{donations}->[0]->{amount},                 '30,00',      'amount');
        is ( $res->{donations}->[0]->{payment_lr},                   '00',         'LR code' );
        is ( $res->{donations}->[0]->{payment_succeded},             'true',       'payment succeded' );
        is ( $res->{donations}->[0]->{payment_message},              'Autorizado', 'payment message' );
        ok ( defined( $res->{donations}->[0]->{name} ),              'donor name is defined');
        ok( defined( $res->{donations}->[0]->{captured_at} ), 'donation captured_at is defined');
        ok( exists( $res->{donations}->[0]->{refunded_at} ), 'donation refunded_at exists');
        ok ( defined( $res->{donations}->[0]->{email} ),             'donor email is defined');
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

    setup_sucess_mock_iugu;
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
