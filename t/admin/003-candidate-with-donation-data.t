use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

use Text::CSV;

my $schema = VotoLegal->model('DB');

db_transaction {

    create_candidate();

    my $name          = fake_name()->();
    my $party_id      = fake_int(1, 35)->();
    my $address_state = 'SP';

    my $party_name = $schema->resultset("Party")->find($party_id)->name;

    create_candidate(
        name          => $name,
        party_id      => $party_id,
        address_state => $address_state
    );

    my $candidate_id = stash "candidate.id";
    my $candidate    = $schema->resultset("Candidate")->find($candidate_id);

    api_auth_as candidate_id => $candidate_id;
    create_candidate_contract_signature($candidate_id);

    $candidate->update(
        {
            raising_goal   => 100.00,
            payment_status => 'paid',
            status         => 'activated',
            is_published   => 1,
            published_at   => \"NOW() - interval '10 days'"
        }
    );

    my $donation = &mock_donation;

    api_auth_as user_id => 1;

    rest_get "/api/admin/candidate-with-donation-data",
        name  => 'get candidates with donation data',
        list  => 1,
        stash => 'get_candidate_donation_data'
    ;

    stash_test "get_candidate_donation_data" => sub {
        my $res = shift;

        is ( scalar @{ $res->{candidates} }, 1, 'only one candidate');

        my $res_candidate = $res->{candidates}->[0];

        is ($res_candidate->{id},                     $candidate_id,  'candidate id');
        is ($res_candidate->{name},                   $name,          'candidate name');
        is ($res_candidate->{party},                  $party_name,    'party');
        is ($res_candidate->{address_state},          $address_state, 'address state');
        is ($res_candidate->{raising_goal},           '100,00',       'candidate raising goal');
		is($res_candidate->{donation_count},           1,              'candidate donation count');
		is($res_candidate->{donation_count},           1,              'candidate donation count');
		is($res_candidate->{amount_boleto},           undef,              'candidate donation count');
        is ($res_candidate->{amount_credit_card},     '30',              'candidate donation count');
        is ($res_candidate->{amount_raised},          '30',           'candidate amount raised');
        is ($res_candidate->{avg_donation_amount},    '30',           'candidate average donation amount');
        is ($res_candidate->{goal_raised_percentage}, '30,000%',      'candidate raising goal percentage');
    }
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