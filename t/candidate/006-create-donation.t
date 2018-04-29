use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    my $candidate_id = stash 'candidate.id';

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

    api_auth_as 'nobody';

    my $cpf = '46223869762';
    generate_device_token;

    rest_post "/api2/donations",
      name   => "add donation",
      stash => 'donation',
      code   => 200,
      params => {
        generate_rand_donator_data(),

        candidate_id   => stash 'candidate.id',
        device_authorization_token_id     => stash 'test_auth',
        payment_method => 'credit_card',
        cpf            => $cpf,
        amount         => 3000,
      };





};

done_testing();
