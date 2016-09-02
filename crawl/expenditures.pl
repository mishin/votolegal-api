#!/usr/bin/env perl
use common::sense;
use open q(:locale);
use FindBin qw($Bin);
use lib "$Bin/../lib";

use JSON;
use Time::HiRes;
use File::Temp qw(tempdir);
use Digest::MD5 qw(md5_hex);
use VotoLegal::SchemaConnected;
use LWP::UserAgent::OfflineCache;
use Business::BR::CPF qw(test_cpf);
use Business::BR::CNPJ qw(test_cnpj);

my $schema = get_schema();
my $ua = LWP::UserAgent::OfflineCache->new(
    cache_dir => tempdir(CLEANUP => 1),
    delay     => 0,
);

my @candidates = $schema->resultset('Candidate')->search({
    status         => "activated",
    payment_status => "paid",
})->all();

for my $candidate (@candidates) {
    printf "Processando o candidato '%s' (id #%d).\n",   $candidate->name, $candidate->id;

    # Estado.
    printf "Buscando o código do estado do candidato '%d'\n", $candidate->id;
    my $state = $schema->resultset('State')->search({ name => $candidate->address_state })->next->code
      or die "Não foi possível encontrar o estado de nome '" . $candidate->address_state . "'";

    # Município.
    printf "Buscando id do município do candidato '%d'.\n", $candidate->id;
    my $reqCity = $ua->get(
        "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/eleicao/buscar/${state}/2/municipios"
    );

    my $cities = decode_json $reqCity;

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
    my $officeReq = $ua->get(
        "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/eleicao/listar/municipios/2/${cityCode}/cargos"
    );
    my $offices = decode_json $officeReq;

    my $officeCode;
    for (@{ $offices->{cargos} }) {
        if ($_->{nome} eq $candidate->office->name) {
            $officeCode = $_->{codigo};
            last;
        }
    }

    # Listando os candidatos que concorrem ao mesmo cargo.
    my $candidatesReq = $ua->get(
        "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/candidatura/listar/2016/$cityCode/2/$officeCode/candidatos"
    );
    my $candidates = decode_json $candidatesReq;

    # A API do TSE só pode estar de brinks: o campo 'cnpjcampanha' nesta ultima request não é populado, sempre vem
    # null. Serei obrigado a entrar na página de cada candidato para confrontar o CNPJ.
    for (@{ $candidates->{candidatos} }) {
        # Ao menos temos uma informação interessante: o partido. Se o candidato não for do mesmo partido o qual estou
        # buscando, já nem procuro o CNPJ dele.
        next unless $candidate->party->acronym eq $_->{partido}->{sigla};

        my $candidateId = $_->{id};

        my $candidateReq = $ua->get(
            "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/candidatura/buscar/2016/$cityCode/2/candidato/$candidateId"
        );

        my $candidateData = decode_json $candidateReq;

        my $cnpj = $candidate->cnpj;
        $cnpj =~ s/\D//g;

        # Se o CNPJ bater, legal, encontrei o candidato! Vamos buscar as doações recebidas pelo mesmo.
        if ($cnpj eq $candidateData->{cnpjcampanha}) {
            printf "Legal, o candidato id '%d' de cnpj '%s' bateu com o cnpj '%s'!\n",
                $candidate->id,
                $candidate->cnpj,
                $candidateData->{cnpjcampanha}
            ;

            # Para obter as receitas eu preciso do numero do partido e do número do candidato.
            my $numPartido   = $candidateData->{partido}->{numero};
            my $numCandidato = $candidateData->{numero};

            # Obtendo numero do prestador.
            my $prestadorReq = $ua->get(
                "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/prestador/consulta/2/2016/$cityCode/11/$numPartido/$numCandidato/$candidateId"
            );

            my $prestador = decode_json $prestadorReq;

            # Eu não faço ideia a que se refere esses números, mas descobri que preciso deles.
            my $sqEntregaPrestacao = $prestador->{dadosConsolidados}->{sqEntregaPrestacao};
            my $sqPrestadorConta   = $prestador->{dadosConsolidados}->{sqPrestadorConta};

            if (!defined($sqEntregaPrestacao) || !defined($sqPrestadorConta)) {
                printf "O candidato '%s' (id %d) não prestou contas das declarações.\n", $candidate->name, $candidate->id;
                next;
            }

            printf "Buscando as despesas do candidato id '%d'.\n", $candidate->id;
            my $reqDespesas = $ua->get(
                "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/prestador/consulta/despesas/2/$sqPrestadorConta/$sqEntregaPrestacao"
            );

            my $despesas = decode_json $reqDespesas;

            for my $despesa (@{ $despesas }) {
                # Validando CNPJ ou CPF.
                my $cpjCnpjFornecedor = $despesa->{cpjCnpjFornecedor} || "";
                next if !test_cnpj($cpjCnpjFornecedor) && !test_cpf($cpjCnpjFornecedor);

                # Buscando a despesa no banco de dados.
                my $expenditure = $candidate->expenditures->search({
                    cpf_cnpj        => $cpjCnpjFornecedor,
                    date            => $despesa->{data},
                    amount          => $despesa->{valor} * 100,
                    type            => $despesa->{tipoDespesa},
                    document_number => $despesa->{numeroDocumento},
                    resource_specie => $despesa->{especieRecurso},
                    document_specie => $despesa->{especieDocumento},
                })->next;

                if (ref $expenditure) {
                    printf "A despesa do candidato '%d' do cpf/cnpj %s no valor de R\$ %.2f já estava registrada.\n",
                        $candidate->id,
                        $cpjCnpjFornecedor,
                        $despesa->{valor},
                    ;
                }
                else {
                    printf "Armazenando a despesa do candidato '%d' do cpf/cnpj %s no valor de R\$ %.2f.\n",
                        $candidate->id,
                        $cpjCnpjFornecedor,
                        $despesa->{valor},
                    ;

                    $candidate->expenditures->create({
                        name            => $despesa->{nomeFornecedor},
                        cpf_cnpj        => $cpjCnpjFornecedor,
                        date            => $despesa->{data},
                        amount          => $despesa->{valor} * 100,
                        type            => $despesa->{tipoDespesa},
                        document_number => $despesa->{numeroDocumento},
                        resource_specie => $despesa->{especieRecurso},
                        document_specie => $despesa->{especieDocumento},
                    });
                }
            }
            last;
        }
        else {
            printf "O cnpj '%s' do candidato id '%d' não bateu com '%s'.\n",
                $candidate->cnpj,
                $candidate->id,
                $candidateData->{cnpjcampanha}
            ;
        }
    }
}

