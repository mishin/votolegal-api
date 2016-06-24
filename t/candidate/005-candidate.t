use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;

    my $candidate_id = stash 'candidate.id';

    rest_get "/api/candidate/${candidate_id}",
        name => 'get candidate',
        stash => 'get',
    ;

    my $candidate = $schema->resultset('Candidate')->find($candidate_id);

    stash_test 'get' => sub {
        my ($res) = @_;

        # Testando se todos os campos que vieram no GET correspondem ao candidato criado.
        for (keys %{$res->{candidate}}) {
            is ($candidate->$_, $res->{candidate}->{$_}, $_);
        }
    };
};

done_testing();

