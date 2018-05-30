package WebService::CEP::Postmon;

use Moose::Role;
use feature 'state';

use Furl;
use JSON qw(decode_json);

sub name { 'Postmon' }

sub _find {
    state $ua = Furl->new( timeout => 4 );

    my $cep = pop;
    my $res = $ua->get( 'http://api.postmon.com.br/v1/cep/' . $cep );

    return unless $res->is_success;

    my $r = eval { decode_json( $res->content ) } or return;

    my $street = $r->{logradouro} || '';
    ($street) = $street =~ /^(.*?)(?:\s+-\s+.*)?$/g;

    return {
        street   => $street,
        city     => $r->{cidade},
        district => $r->{bairro},
        state    => $r->{estado},
    };
}

1;