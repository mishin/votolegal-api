use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my ( $response, $donation_url );
my $schema = VotoLegal->model('DB');
my $cpf    = '46223869762';

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

    # Aprovando o candidato.
    ok(
        $schema->resultset('Candidate')->find($candidate_id)->update(
            {
                status         => "activated",
                payment_status => "paid",
                is_published   => 1,
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

    api_auth_as 'nobody';

    generate_device_token;
    set_current_dev_auth( stash 'test_auth' );

    is $schema->resultset('DonationFpDetail')->count, 0, 'no DonationFpDetail inserted';

    $response = rest_post "/api2/donations",
      name   => "add donation",
      params => {
        generate_rand_donator_data_cc(),

        donation_fp => 'eyJpZCI6ImVycm9yIiwgIm1zZyI6ICJqcyBlcnJvciBoZXJlIn0=',

        candidate_id                  => stash 'candidate.id',
        device_authorization_token_id => stash 'test_auth',
        payment_method                => 'credit_card',
        cpf                           => $cpf,
        amount                        => 3000,
      };
    my $id_donation_of_3k = $response->{donation}{id};

    set_current_donation $id_donation_of_3k;
    assert_current_step('credit_card_form');

    is $schema->resultset('DonationFpDetail')->count, 1, 'one DonationFpDetail inserted';

    my $fp = $schema->resultset('DonationFp')->next;

    is $fp->fp_hash, 'error', 'hash is error';
    is $fp->donation_fp_details->next->donation_fp_value->value, 'js error here', 'accept js error on FP';

};

done_testing();

exit;

