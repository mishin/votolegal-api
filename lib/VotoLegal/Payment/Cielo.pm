package VotoLegal::Payment::Cielo;
use common::sense;
use Moose;

use Carp qw(croak);
use URI;
use XML::Simple;
use Unix::Whereis;
use File::Temp qw(tempfile);
use Digest::MD5 qw(md5_hex);

use VotoLegal::Payment::Cielo::XMLAPI;

with 'VotoLegal::Payment';

BEGIN { whereis("curl") or die "could not find 'curl' in your PATH." }

has affiliation => (
    is       => "rw",
    required => 1,
);

has key => (
    is       => "rw",
    required => 1,
);

has soft_descriptor => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has api => (
    is       => "ro",
    default  => sub { VotoLegal::Payment::Cielo::XMLAPI->new() },
);

has sandbox => (
    is       => "rw",
    isa      => "Bool",
    required => 1,
);

my $domains = {
    sandbox    => "https://qasecommerce.cielo.com.br/servicos/ecommwsec.do",
    production => "https://ecommerce.cielo.com.br/servicos/ecommwsec.do",
};

sub tokenize_credit_card {
    my ( $self, %opts ) = @_;

    my $xml = $self->api->get_token(
        validade  => $opts{credit_card_data}->{credit_card}->{validity},
        portador  => $opts{credit_card_data}->{credit_card}->{name_on_card},
        numero    => $opts{credit_card_data}->{secret}->{number},
        afiliacao => $self->affiliation,
        chave     => $self->key,
    );

    my $ret = $self->_run_curl(xml => $xml);

    if ($ret->{token}->{'dados-token'}->{'codigo-token'} && $ret->{token}->{'dados-token'}->{'status'} == 1) {
        return $ret->{token}->{'dados-token'}->{'codigo-token'};
    }

    croak 'tokenize_credit_card failed';
}

sub do_authorization {
    my ( $self, %opts ) = @_;

    croak 'missing token' unless $opts{token};

    my $xml = $self->api->do_payment(
        pedido          => substr(md5_hex( $opts{remote_id} ), 0, 20),
        token           => $opts{token},
        bandeira        => $self->_brand_to_bandeira($opts{brand}),
        afiliacao       => $self->affiliation,
        chave           => $self->key,
        soft_descriptor => $opts{soft_descriptor} ? $opts{soft_descriptor} : $self->soft_descriptor,
        valor           => $opts{amount},
        autorizar       => 3,       # autorizar nao presente
        capturar        => 'false', # apenas reservar o dinheiro.
        moeda           => 986,     # Reais
        idioma          => 'PT',    # portugues
        produto         => 1,       # credito a vista
        parcelas        => 1,
    );

    my $ret = $self->_run_curl(xml => $xml);

    die 'resposta nao esperada' unless ref $ret->{autorizacao} eq 'HASH';

    return {
        captured       => $ret->{autorizacao}{codigo} == 6,
        authorized     => $ret->{autorizacao}{codigo} == 4,
        transaction_id => $ret->{tid}
    };
}

sub do_capture {
    my ( $self, %opts ) = @_;

    croak 'missing transaction_id' unless $opts{transaction_id};

    my $xml = $self->api->capture_payment(
        tid       => $opts{transaction_id},
        afiliacao => $self->affiliation,
        chave     => $self->key,
    );

    my $ret = $self->_run_curl(xml => $xml);

    die 'resposta nao esperada' unless ref $ret->{autorizacao} eq 'HASH';

    return {
        captured       => $ret->{autorizacao}{codigo} == 6,
        authorized     => $ret->{autorizacao}{codigo} == 4,
        transaction_id => $ret->{tid}
    };
}

sub _run_curl {
    my ( $self, %opts ) = @_;

    my $curl_bin = whereis("curl");

    my ($fh,  $filename)  = tempfile();
    my ($fh2, $filename2) = tempfile();

    my $content = { mensagem => $opts{xml} };
    my $url = URI->new('https:');
    $url->query_form( ref($content) eq "HASH" ? %$content : @$content );
    $content = $url->query;
    $content =~ s/(?<!%0D)%0A/%0D%0A/g if defined($content);

    print $fh $content;

    $url = $domains->{ $self->sandbox ? 'sandbox' : 'production' };

    my $can_try_again = 1;
  AGAIN:

    my $res = `($curl_bin --connect-timeout 10 --max-time 40 --tlsv1.0 -X POST -d \@$filename $url ) 2>$filename2`;

    if ($? == 0) {
        return $res = XMLin($res);
    }
    else {
        # Timeout...
        if ($can_try_again == 1 && $? == 28) {
            $can_try_again = 0;
            goto AGAIN;
        }
    }

    return;
}

sub _brand_to_bandeira {
    my ($self, $brand) = @_;

    my $from_to = {
        'visa'            => 'visa',
        'mastercard'      => 'mastercard',
        'discover'        => 'discover',
        'enroute'         => 'diners',
        'jcb'             => 'jcb',
        'americanexpress' => 'amex',
        'elo'             => 'elo',
        'aura'            => 'aura',
        'diners'          => 'diners',
    };

    return $from_to->{$brand} || croak "brand '$brand' not supported by Cielo PaymentDriver";
}

__PACKAGE__->meta->make_immutable;

1
