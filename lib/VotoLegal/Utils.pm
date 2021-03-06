package VotoLegal::Utils;
use common::sense;

use JSON qw/encode_json/;
use Furl;
use URI;
use URI::QueryParam;
use URI::Escape;
use MIME::Base64 qw(encode_base64url decode_base64url);

use UUID::Tiny qw/uuid_to_string string_to_uuid/;

use Data::Dumper qw/Dumper/;
my $alert_used;
my $furl = Furl->new( timeout => 5 );

use vars qw(@ISA @EXPORT);

@ISA    = (qw(Exporter));
@EXPORT = qw(
    is_test left_padding_zeros left_padding_whitespaces die_with remote_notify die_with_reason
    gen_page_marker
    parse_page_marker
);

=head1 METHODS

=head2 is_test()

Retorna 1 caso esteja rodando em uma suíte de testes.

=cut

sub is_test {
    if ( $ENV{HARNESS_ACTIVE} || $0 =~ m{forkprove} ) {
        return 1;
    }
    return 0;
}

sub left_padding_zeros {
    my ( $string, $pos ) = @_;

    my $padded = sprintf( "%0${pos}s", $string );
    $padded =~ tr/ /0/;

    return $padded;
}

sub left_padding_whitespaces {
    my ( $string, $pos ) = @_;

    return sprintf( "%0${pos}s", $string );
}

sub right_padding_whitespaces {
    my ( $string, $pos ) = @_;

    $pos = $pos + length $string;
    return sprintf( "%-${pos}s", $string );
}

sub die_with ($) {
    die { msg_id => shift };
}

sub die_with_reason ($$) {
    die { msg_id => shift, reason => shift };
}

my $already_notifed;

sub remote_notify {
    my ( $text, %opts ) = @_;

    if ( ref $text ne '' ) {
        $text = Dumper($text);
    }

    if ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) {
        eval('use DDP; p $text');

        if ( !$alert_used ) {
            system( 'notify-send', '--urgency=low', $text );
            $alert_used++;
        }
        return 1;
    }

    if ( exists $ENV{VOTOLEGAL_HANGOUTS_CHAT_URL} ) {
        my $hostname = `hostname`;
        chomp($hostname);

        my $uri = URI->new( $ENV{VOTOLEGAL_HANGOUTS_CHAT_URL} );
        $uri->query_param_append( 'thread_key', $opts{channel} || 'error' );

        $text = substr( $text, 0, 2000);

        return 1 if exists $already_notifed->{$text};
        $already_notifed->{$text} = 1;


        my $x = eval {
            $furl->post(
                $uri->as_string,
                [ 'Content-type' => 'application/json' ],
                encode_json( { text => $hostname . ' ' . $text } )
            );
        };
        print STDERR "Error while sending remote_notify $text - $@" if $@;
    }

}

sub gen_page_marker {
    my ( $time_col, $id_column, $rows, %opts ) = @_;

    my $compress = $opts{compress_id_from_uuid};

    # 0 rows
    return undef unless @$rows;

    my $marker = $rows->[-1]{$time_col};

    sub _check_or_die {
        die 'cannot gen_page_marker because columns have unescaped chars' if $_[0] =~ /(\s|\*)/o;
    }

    my $last_time = $marker;
    _check_or_die($marker);

    # reverse loop until find a different time
    for my $row ( reverse @$rows ) {

        my $row_time = $row->{$time_col};

        if ( $row_time eq $last_time ) {

            my $id = $row->{$id_column};

            if ($compress) {

                $marker .= '*' . encode_base64url( string_to_uuid($id) );

            }
            else {

                _check_or_die($id);
                $marker .= ' ' . $id;

            }

        }
        else {
            last;
        }

    }

    return $marker;

}

sub parse_page_marker {
    my ($str) = @_;

    my ( $time, $id_str, @ids );
    if ( $str =~ / / ) {

        ( $time, $id_str ) = split / /, $str, 2;

        @ids = split / /, $id_str;

    }
    else {
        ( $time, $id_str ) = split /\*/, $str, 2;
        @ids = map { uuid_to_string( decode_base64url($_) ) } split /\*/, $id_str;
    }

    return ( $time, @ids );

}

1;
