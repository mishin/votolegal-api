package WebService::CEP::Correios;

use Moose::Role;
use WWW::Correios::CEP;
use feature 'state';

sub name { 'Correios' }

sub _find {
    state $cepper = WWW::Correios::CEP->new;
    my $r = $cepper->find(pop);

    return
         if defined $r
      && ref $r eq 'HASH'
      && exists $r->{status}
      && $r->{status} =~ /erro/i;

    my $street = $r->{street};
    ($street) = $street =~ /^(.*?)(?:\s+-\s+.*)?$/g;

    return {
        street   => $street,
        city     => $r->{location},
        district => $r->{neighborhood},
        state    => $r->{uf},
    };
}

1;