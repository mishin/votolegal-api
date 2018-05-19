package VotoLegal::Utils;
use common::sense;

use JSON qw/encode_json/;
use Furl;
use URI;
use URI::QueryParam;
use URI::Escape;

my $alert_used;
my $furl = Furl->new( timeout => 5 );

use vars qw(@ISA @EXPORT);

@ISA    = (qw(Exporter));
@EXPORT = qw(is_test left_padding_zeros left_padding_whitespaces die_with remote_notify die_with_reason);

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

sub die_with ($) {
    die { msg_id => shift };
}

sub die_with_reason ($$) {
    die { msg_id => shift, reason => shift };
}


sub remote_notify {
    my ( $text, %opts ) = @_;

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
1;
