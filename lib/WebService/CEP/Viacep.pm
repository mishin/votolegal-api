package WebService::CEP::Viacep;

use Moose::Role;
use feature 'state';

use Furl;
use JSON qw(decode_json);
sub name { 'Viacep' }

sub _find {
    state $ua = Furl->new( timeout => 4 );

    my $cep = pop;
    my $res = $ua->get("http://viacep.com.br/ws/$cep/json/");

    return unless $res->is_success;

    my $r = eval { decode_json( $res->content ) } or return;

    return unless ref $r eq 'HASH';

    return if exists $r->{erro} && $r->{erro};

    my $street = $r->{logradouro};
    ($street) = $street =~ /^(.*?)(?:\s+-\s+.*)?$/g;

    return {
        street   => $r->{logradouro},
        city     => $r->{localidade},
        district => $r->{bairro},
        state    => $r->{uf},
    };
}

1;