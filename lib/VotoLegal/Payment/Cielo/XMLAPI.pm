package VotoLegal::Payment::Cielo::XMLAPI;
use common::sense;
use Moose;
use Carp 'croak';
use Template;
use POSIX qw(strftime);
use Data::Section::Simple qw(get_data_section);

my $template = Template->new( TRIM => 1, );

sub do_payment {
    my ($self, %p) = @_;

    &_check_options(\%p);

    croak 'param valor must be integer'             unless $p{valor} =~ /^[0-9]+$/;
    croak 'param pedido is not defined'             unless $p{pedido};
    croak 'param parcelas is not a number'          unless $p{parcelas} =~ /^[0-9]+$/;
    croak 'param validade must be in AAAAMM format' if !$p{token} && ( $p{validade} !~ /^[0-9]{6}$/ );
    croak 'param numero is not defined'             if !$p{token} && !$p{numero};

    # indica se o codigo_seguranca esta presente.
    $p{indicador}       = 1;
    $p{data}            = strftime( '%Y-%m-%dT%H:%M:%S', gmtime ) . '-00:00';
    $p{soft_descriptor} = substr( $p{soft_descriptor}, 0, 13 );

    for (qw(chave afiliacao pedido valor produto parcelas soft_descriptor)) {
        croak "param $_ is not defined" unless $p{$_};
    }

    my $xml = '';
    my $tt  = get_data_section('transacao.xml');
    $template->process( \$tt, \%p, \$xml );
    $xml =~ s/^ +//gm;

    return $xml;
}

sub get_token {
    my ($self, %p) = @_;

    croak 'param validade: AAAAMM'      unless $p{validade} =~ /^[0-9]{6}$/;
    croak 'param numero is not defined' unless $p{numero};

    for (qw(chave afiliacao numero validade portador)) {
        croak "param $_ is not defined" unless $p{$_};
    }

    my $xml = '';
    my $tt  = get_data_section('token.xml');
    $template->process( \$tt, \%p, \$xml );
    $xml =~ s/^ +//gm;

    return $xml;
}

sub cancel_payment {
    my ($self, %p) = @_;

    for (qw(tid afiliacao chave)) {
        croak "param $_ is not defined" unless $p{$_};
    }

    my $xml = '';
    my $tt  = get_data_section('cancelamento.xml');
    $template->process( \$tt, \%p, \$xml );
    $xml =~ s/^ +//gm;

    return $xml;
}

sub capture_payment {
    my ($self, %p) = @_;

    for (qw/tid afiliacao chave/) {
        croak "param $_ is not defined" unless $p{$_};
    }

    my $xml = '';
    my $tt  = get_data_section('captura.xml');
    $template->process( \$tt, \%p, \$xml );
    $xml =~ s/^ +//gm;

    return $xml;
}

sub get_transaction_details {
    my ($self, %p) = @_;

    for (qw(tid afiliacao chave)) {
        croak "param $_ is not defined" unless $p{$_};
    }

    my $xml = '';
    my $tt  = get_data_section('consulta.xml');
    $template->process( \$tt, \%p, \$xml );
    $xml =~ s/^ +//gm;

    return $xml;
}

sub _check_options {
    my ($options) = @_;

    croak 'option idioma: must be PT, EN or ES'    unless $options->{idioma} =~ /^(PT|EN|ES)$/;
    croak 'option capturar: must be false or true' unless $options->{capturar} =~ /^(false|true)$/;
    croak 'option moeda: must be fixed 986'        unless $options->{moeda} eq '986';
    croak 'option produto: must be 1, 2, 3 or A'   unless $options->{produto} =~ /^[123A]$/;
    croak 'option autorizar: must be 0, 1, 2, 3'   unless $options->{autorizar} =~ /^[01234]$/;
    croak 'option bandeira: must be visa, diners, elo, discover, mastercard, jcb, aura OR amex'
      unless $options->{bandeira} =~ /^(visa|diners|elo|discover|mastercard|amex|jcb|aura)$/;
}

1;

__DATA__

@@ consulta.xml

<?xml version="1.0" encoding="UTF-8"?>
<requisicao-consulta id="5" versao="1.2.0">
    <tid>[% tid %]</tid>
    <dados-ec>
        <numero>[% afiliacao %]</numero>
        <chave>[% chave %]</chave>
    </dados-ec>
</requisicao-consulta>

@@ captura.xml

<?xml version="1.0" encoding="ISO-8859-1"?>
<requisicao-captura id="adbc9961-8a39-452b-b7fd-15b44b464a97" versao="1.3.0">
    <tid>[% tid %]</tid>
    <dados-ec>
        <numero>[% afiliacao %]</numero>
        <chave>[% chave %]</chave>
    </dados-ec>
</requisicao-captura>


@@ cancelamento.xml

<?xml version="1.0" encoding="ISO-8859-1"?>
    <requisicao-cancelamento id="7" versao="1.1.1" xmlns="http://ecommerce.cbmp.com.br">
        <tid>[% tid %]</tid>
    <dados-ec>
        <numero>[% afiliacao %]</numero>
        <chave>[% chave %]</chave>
    </dados-ec>
</requisicao-cancelamento>

@@ transacao.xml

<?xml version="1.0" encoding="ISO-8859-1"?>
<requisicao-transacao versao="1.2.1" id="C15D260E-98F1-49A3-ADDC-2D6ABF949A0E" xmlns="http://ecommerce.cbmp.com.br">
    <dados-ec>
        <numero>[% afiliacao %]</numero>
        <chave>[% chave %]</chave>
    </dados-ec>
    <dados-portador>
        [%- IF token %]
        <token>[% token %]</token>
        [% ELSE %]
         <numero>[% numero %]</numero>
         <validade>[% validade %]</validade>
         <indicador>[% indicador %]</indicador>
        [% IF codigo_seguranca %]<codigo-seguranca>[% codigo_seguranca %]</codigo-seguranca>[% END %]
        [% IF portador %]<nome-portador>[% portador %]</nome-portador>[% END %]
        [% END -%]
    </dados-portador>
    <dados-pedido>
        <numero>[% pedido %]</numero>
        <valor>[% valor %]</valor>
        <moeda>[% moeda %]</moeda>
        <data-hora>[% data %]</data-hora>
        <idioma>[% idioma %]</idioma>
        <soft-descriptor>[% soft_descriptor %]</soft-descriptor>
        [%- IF descricao%]<descricao>[%descricao%]</descricao>[% END %]
    </dados-pedido>
    <forma-pagamento>
        <bandeira>[% bandeira %]</bandeira>
        <produto>[% produto %]</produto>
        <parcelas>[% parcelas %]</parcelas>
    </forma-pagamento>
    <url-retorno>null</url-retorno>
    <autorizar>[% autorizar %]</autorizar>
    <capturar>[% capturar %]</capturar>
    [%- UNLESS token %]<gerar-token>true</gerar-token>[% END -%]
</requisicao-transacao>

@@ token.xml

<?xml version="1.0" encoding="ISO-8859-1"?>
<requisicao-token id="8fc889c7-004f-42f1-963a-31aa26f75e5c" versao="1.2.1">
    <dados-ec>
        <numero>[% afiliacao %]</numero>
        <chave>[% chave %]</chave>
    </dados-ec>
    <dados-portador>
         <numero>[% numero %]</numero>
         <validade>[% validade %]</validade>
        [% IF codigo_seguranca %]<codigo-seguranca>[% codigo_seguranca %]</codigo-seguranca>[% END %]
        <nome-portador>[% portador %]</nome-portador>
    </dados-portador>
</requisicao-token>
