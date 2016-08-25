#!/usr/bin/env perl
use common::sense;
use open q(:locale);
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Furl;
#use LWP::UserAgent::Cached;
use JSON::XS;
use VotoLegal::SchemaConnected;
use HTML::TreeBuilder::XPath;

use Data::Printer;

my $schema = get_schema();
my $furl   = Furl->new();

my @candidates = $schema->resultset('Candidate')->search({
    status         => "activated",
    payment_status => "paid",
    office_id      => 1,
})->all();

for my $candidate (@candidates) {
    printf "Processando o candidato '%s' (id #%d).\n",   $candidate->name, $candidate->id;

    # Estado.
    printf "Buscando o código do estado do candidato '%d'\n", $candidate->id;
    my $state = $schema->resultset('State')->search({ name => $candidate->address_state })->next->code
      or die "Não foi possível encontrar o estado de nome '" . $candidate->address_state . "'";

    # Município.
    printf "Buscando id do município do candidato '%d'.\n", $candidate->id;
    my $reqCity = $furl->get(
        "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/eleicao/buscar/${state}/2/municipios"
    );

    my $cities = decode_json $reqCity->content;

    my $cityCode ;
    for (@{ $cities->{municipios} }) {
        if ($_->{nome} eq uc($candidate->address_city)) {
            $cityCode = $_->{codigo};
            last;
        }
    }
    defined $cityCode or die "Não foi possível encontrar o município '" . $candidate->address_city . "'";

    # Buscando o código do cargo.
    printf "Buscando os cargos do município do candidato '%d'.\n", $candidate->id;
    my $officeReq = $furl->get(
        "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/eleicao/listar/municipios/2/${cityCode}/cargos"
    );
    my $offices = decode_json $officeReq->content;

    my $officeCode;
    for (@{ $offices->{cargos} }) {
        if ($_->{nome} eq $candidate->office->name) {
            $officeCode = $_->{codigo};
            last;
        }
    }

    # Listando os candidatos que concorrem ao mesmo cargo.
    my $candidatesReq = $furl->get(
        "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/candidatura/listar/2016/$cityCode/2/$officeCode/candidatos"
    );
    my $candidates = decode_json $candidatesReq->content;

    # A API do TSE só pode estar de brinks: o campo 'cnpjcampanha' nesta ultima request não é populado, sempre vem
    # null. Serei obrigado a entrar na página de cada candidato para confrontar o CNPJ.
    for (@{ $candidates->{candidatos} }) {
        # Ao menos temos uma informação interessante: o partido. Se o candidato não for do mesmo partido o qual estou
        # buscando, já nem procuro o CNPJ dele.
        next unless $candidate->party->acronym eq $_->{partido}->{sigla};

        my $candidateId = $_->{id};

        my $candidateReq = $furl->get(
            "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/candidatura/buscar/2016/$cityCode/2/candidato/$candidateId"
        );

        my $candidateData = decode_json $candidateReq->content;

        my $cnpj = $candidate->cnpj;
        $cnpj =~ s/\D//g;

        # TODO Obter o prestador de http://divulgacandcontas.tse.jus.br/divulga/rest/v1/prestador/consulta/2/2016/71072/11/18/18/250000015112
        # http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/71072/250000015112/integra/receitas

        # Se o CNPJ bater, legal, encontrei o candidato! Vamos buscar as doações recebidas pelo mesmo.
        #if ($cnpj eq $candidateData->{cnpjcampanha}) {
        #    #p $cnpj;
        #    last;
        #}
    }


    # http://divulgacandcontas.tse.jus.br/divulga/#/
    # TODO Buscando doações.
    # TODO Salvando doações no banco de dados.
    last;
}
