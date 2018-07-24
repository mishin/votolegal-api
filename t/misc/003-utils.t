use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::More;

use_ok 'VotoLegal::Utils';

ok( is_test(), 'is_test' );

&test_gen_marker;

done_testing();

exit;

sub test_gen_marker {

    my $rows = [

        {
            id          => "0c8b534c-8a04-11e8-918b-376081f18cf2",
            captured_at => "1531995268",
        },
        {
            id          => "481897be-89f3-11e8-918b-6bea98c39142",
            captured_at => "1531995265",
        },
        {
            id          => "eb0e1454-8a1a-11e8-918b-9b23b8b5a6e1",
            captured_at => "1531995264",
        },
    ];

    is(
        gen_page_marker( 'captured_at', 'id', $rows ),
        '1531995264 eb0e1454-8a1a-11e8-918b-9b23b8b5a6e1',
        'only one id to ignore'
    );

    push @$rows,
      {
        id          => "eb0e1454-8a1a-11e8-918b-9b23b8b5a6e2",
        captured_at => "1531995264",
      };

    is(
        gen_page_marker( 'captured_at', 'id', $rows ),
        '1531995264 eb0e1454-8a1a-11e8-918b-9b23b8b5a6e2 eb0e1454-8a1a-11e8-918b-9b23b8b5a6e1',
        'two ids to ignore'
    );

    is(
        gen_page_marker( 'captured_at', 'id', $rows, compress_id_from_uuid => 1 ),
        '1531995264*6w4UVIoaEeiRi5sjuLWm4g*6w4UVIoaEeiRi5sjuLWm4Q',
        'compressing worked'
    );

    my ( $time, @ids ) = parse_page_marker('1531995264*6w4UVIoaEeiRi5sjuLWm4g*6w4UVIoaEeiRi5sjuLWm4Q');

    is( $time, '1531995264', 'time extraction ok' );
    is_deeply(
        \@ids,
        [qw/eb0e1454-8a1a-11e8-918b-9b23b8b5a6e2 eb0e1454-8a1a-11e8-918b-9b23b8b5a6e1/],
        'uuid parsed ok'
    );

    # testing errors
    my $test = [@$rows];
    push @$test,
      {
        id          => "eb0e1454-8a1a-11e8-918b-9b23b8b5a6e2",
        captured_at => "15319*95264",
      };

    eval { gen_page_marker( 'captured_at', 'id', $test, compress_id_from_uuid => 1 ) };
    like $@, qr/gen_page_marker/, 'gen_page_marker error ok';

    push @$test,
      {
        id      => "eb0e1454-8a1a-11e8-918b-9b23b8b5a6e2",
        another => "15319 95264",
      };

    eval { gen_page_marker( 'another', 'id', $test, compress_id_from_uuid => 1 ) };
    like $@, qr/gen_page_marker/, 'gen_page_marker error ok';

    push @$test,
      {
        id                => "eb0e1454-8a1a-11e8--9b23b8b5a6e2",
        ok_but_id_invalid => "1531995264",
      };

    eval { gen_page_marker( 'ok_but_id_invalid', 'id', $test, compress_id_from_uuid => 1 ) };
    like $@, qr/is no UUID string/, 'is no UUID string error ok';

    push @$test,
      {
        id                => "eb0e1454-8a1a-11e8 9b23b8b5a6e2",
        ok_but_id_invalid => "1531995264",
      };

    eval { gen_page_marker( 'ok_but_id_invalid', 'id', $test ) };
    like $@, qr/gen_page_marker/, 'gen_page_marker error ok';

    push @$test,
      {
        id                => "eb0e1454-8a1a-11e8*9b23b8b5a6e2",
        ok_but_id_invalid => "1531995264",
      };

    eval { gen_page_marker( 'ok_but_id_invalid', 'id', $test ) };
    like $@, qr/gen_page_marker/, 'gen_page_marker error ok';

}
