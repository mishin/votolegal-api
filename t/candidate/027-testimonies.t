use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
	my $candidate_id = stash "candidate.id";
	my $candidate    = $schema->resultset("Candidate")->find($candidate_id);

    api_auth_as candidate_id => $candidate_id;

    rest_post "/api/candidate/$candidate_id/testimony",
        name    => 'create testimony without reviewer name',
        is_fail => 1,
        code    => 400,
        [ reviewer_text => fake_paragraphs(3)->() ]
    ;

    rest_post "/api/candidate/$candidate_id/testimony",
        name    => 'create testimony without reviewer text',
        is_fail => 1,
        code    => 400,
        [ reviewer_name => fake_name()->() ]
    ;

	my $first_reviewer_name = fake_name()->();
	my $first_reviewer_text = fake_paragraphs(3)->();

    rest_post "/api/candidate/$candidate_id/testimony",
        name                => 'create testimony without picture',
        automatic_load_item => 0,
        stash               => 't1',
        [
            reviewer_name => $first_reviewer_name,
            reviewer_text => 'foobar'
        ]
    ;
    my $first_testimony_id = stash 't1.id';

    my $second_reviewer_name = fake_name()->();
	my $second_reviewer_text = fake_paragraphs(3)->();

    rest_post "/api/candidate/$candidate_id/testimony",
        name                => 'create testimony with picture',
        automatic_load_item => 0,
        stash               => 't2',
        files               => { reviewer_picture => "$Bin/picture.jpg" },
        [
            reviewer_name => $second_reviewer_name,
            reviewer_text => $second_reviewer_text
        ]
    ;
    my $second_testimony_id = stash 't2.id';

    rest_get "/api/candidate/$candidate_id/testimony",
        name  => 'get testimonies',
        list  => 1,
        stash => 'get_testimonies'
    ;

    stash_test 'get_testimonies' => sub {
        my $res = shift;

		my $first_testimony  = $res->{testimonies}->[0];
		my $second_testimony = $res->{testimonies}->[1];

        is ( $first_testimony->{id},                 $first_testimony_id,   'testimony id' );
        is ( $first_testimony->{reviewer_name},      $first_reviewer_name,  'first reviewer name' );
        is ( $first_testimony->{reviewer_text},      'foobar',              'first reviewer text' );
        is ( $first_testimony->{reviewer_picture},   undef,                 'first reviewer doesnt have picture' );
        is ( $second_testimony->{id},                $second_testimony_id,  'testimony id' );
        is ( $second_testimony->{reviewer_name},     $second_reviewer_name, 'second reviewer name' );
        is ( $second_testimony->{reviewer_text},     $second_reviewer_text, 'second reviewer text' );
        is ( $second_testimony->{reviewer_picture}, 'https://f24-user-media-dev.s3.amazonaws.com/votolegal/picture/CiN/1521813860//tmp/0ky1vQLNr1.jpg', 'second reviewer picture' );
    };

    rest_put "/api/candidate/$candidate_id/testimony/$first_testimony_id",
        name => 'deactivating one testimony',
        [ active => 0 ]
    ;

    rest_put "/api/candidate/$candidate_id/testimony/$second_testimony_id",
        name => 'Updating second testimony',
        [
            reviewer_name => 'AppCívico',
            reviewer_text => 'foobar'
        ]
    ;

    rest_reload_list 'get_testimonies';

    stash_test 'get_testimonies.list' => sub {
        my $res = shift;

		is ( scalar @{ $res->{testimonies} }, 1, 'only one active testimony' );

		is( $res->{testimonies}->[0]->{id},                $second_testimony_id,  'testimony id' );
		is( $res->{testimonies}->[0]->{reviewer_name},     'AppCívico',           'second reviewer updated name' );
		is( $res->{testimonies}->[0]->{reviewer_text},     'foobar',              'second reviewer updated text' );
    };
};

done_testing();