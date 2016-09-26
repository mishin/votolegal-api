package VotoLegal::Schema::ResultSet::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Text::CSV;
use File::Temp ':seekable';
use Time::HiRes;
use Digest::MD5 qw(md5_hex);
use Data::Verifier;
use Date::Calc qw(check_date);
use Business::BR::CEP qw(test_cep);
use VotoLegal::Types qw(EmailAddress CPF);
use VotoLegal::Utils;

sub resultset {
    my $self = shift;

    return $self->result_source->schema->resultset(@_);
}

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required => 1,
                    type     => "Str",
                },
                email => {
                    required => 1,
                    type     => EmailAddress,
                },
                cpf => {
                    required => 1,
                    type     => CPF,
                },
                phone => {
                    required => 1,
                    type     => "Str",
                    post_check => sub {
                        $_[0]->get_value('phone') =~ m{^\d{10,11}$};
                    },
                },
                address_street => {
                    required => 1,
                    type     => "Str",
                },
                address_house_number => {
                    required => 1,
                    type     => "Int",
                },
                address_district => {
                    required => 1,
                    type     => "Str",
                },
                address_zipcode => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        test_cep($_[0]->get_value('address_zipcode'));
                    },
                },
                address_city => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('address_city');
                        $self->resultset('City')->search({ name => $city })->count;
                    },
                },
                address_state => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('address_state');
                        $self->resultset('State')->search({ code => $state })->count;
                    },
                },
                address_complement => {
                    required => 0,
                    type     => 'Str',
                },
                amount => {
                    required   => 1,
                    type       => "Int",
                    post_check => sub {
                        my $amount = $_[0]->get_value('amount');

                        if ($amount < 1000 || $amount > 106400) {
                            return 0;
                        }
                        return 1;
                    },
                },
                credit_card_name => {
                    required => 1,
                    type     => "Str",
                },
                birthdate => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        my $birthdate = $_[0]->get_value("birthdate");

                        my @date = $birthdate =~ /^(\d{4})-(\d{2})-(\d{2})$/;
                        check_date(@date);
                    },
                },
                billing_address_street => {
                    required => 1,
                    type     => "Str",
                },
                billing_address_house_number => {
                    required => 1,
                    type     => "Int",
                },
                billing_address_district => {
                    required => 1,
                    type     => "Str",
                },
                billing_address_zipcode => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        test_cep($_[0]->get_value('billing_address_zipcode'));
                    },
                },
                billing_address_city => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('billing_address_city');
                        $self->resultset('City')->search({ name => $city })->count;
                    },
                },
                billing_address_state => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('billing_address_state');
                        $self->resultset('State')->search({ code => $state })->count;
                    },
                },
                billing_address_complement => {
                    required => 0,
                    type     => "Str",
                },
                ip_address => {
                    required => 1,
                    type     => "Str",
                },
                candidate_id => {
                    required => 1,
                    type     => "Int",
                },
                notification_url => {
                    required => 0,
                    type     => "Str",
                },
                payment_gateway_id => {
                    required   => 1,
                    type       => "Int",
                    post_check => sub {
                        my $payment_gateway_id = $_[0]->get_value('payment_gateway_id');
                        $self->resultset('PaymentGateway')->find($payment_gateway_id);
                    },
                },
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            # Buscando uma possível doação repetida. Se aconteceu há menos de 15min, travamos o processo.
            my $repeatedDonation = $self->search({
                candidate_id => $values{candidate_id},
                cpf          => $values{cpf},
                amount       => $values{amount},
                created_at   => { ">=" => \"(now() - '15 minutes'::interval)" },
            })->next;

            if ($repeatedDonation) {
                die \['donation', 'repeated'];
            }

            my $id = md5_hex(Time::HiRes::time());

            return $self->create({
                id                           => $id,
                candidate_id                 => $values{candidate_id},
                name                         => $values{name},
                email                        => $values{email},
                cpf                          => $values{cpf},
                phone                        => $values{phone},
                amount                       => $values{amount},
                birthdate                    => $values{birthdate},
                ip_address                   => $values{ip_address},
                address_state                => $values{address_state},
                address_city                 => $values{address_city},
                address_district             => $values{address_district},
                address_zipcode              => $values{address_zipcode},
                address_street               => $values{address_street},
                address_complement           => $values{address_complement},
                address_house_number         => $values{address_house_number},
                billing_address_street       => $values{billing_address_street},
                billing_address_house_number => $values{billing_address_house_number},
                billing_address_district     => $values{billing_address_district},
                billing_address_zipcode      => $values{billing_address_zipcode},
                billing_address_city         => $values{billing_address_city},
                billing_address_state        => $values{billing_address_state},
                billing_address_complement   => $values{billing_address_complement},
                payment_gateway_id           => $values{payment_gateway_id},
                status                       => "created",
                species                      => "Cartão de crédito",
                by_votolegal                 => "true",
                donation_type_id             => 1,
            });
        },
    };
}

sub export {
    my ($self, $receipt_id) = @_;

    my $fh = File::Temp->new(UNLINK => 1);
    $fh->autoflush(1);

    $self->count or die \['date', "no donations"];

    my $count       = 0;
    my $writeHeader = 1;
    while (my $donation = $self->next()) {
        # Tratando alguns campos do candidato.
        my $cnpj                = $donation->candidate->cnpj;
        $cnpj                   =~ s/\D+//g;
        $cnpj                   = left_padding_zeros($cnpj, 14);
        my $data_movimentacao   = DateTime->now(time_zone => "America/Sao_Paulo")->strftime("%d%m%Y%H%M");
        my $bank_code           = left_padding_zeros($donation->candidate->bank_code, 3);
        my $bank_agency         = left_padding_zeros($donation->candidate->bank_agency, 8);
        my $bank_agency_dv      = left_padding_zeros($donation->candidate->bank_agency_dv, 2);
        my $bank_account_number = left_padding_zeros($donation->candidate->bank_account_number, 18);
        my $bank_account_dv     = left_padding_zeros($donation->candidate->bank_account_dv, 2);

        # Escrevendo o header.
        if ($writeHeader) {
            print $fh "1";                     # Registro.
            print $fh $cnpj;                   # CNPJ.
            print $fh $data_movimentacao;      # Data da movimentação.
            print $fh $bank_code;              # Código do banco.
            print $fh $bank_agency;            # Numero da agência.
            print $fh $bank_agency_dv;         # Dígito verificador da agência.
            print $fh $bank_account_number;    # Número da conta.
            print $fh $bank_account_dv;        # Digito verificador da conta.
            print $fh "400";                   # Versao do layout.
            print $fh "DOACINTE";              # Nome do layout.
            print $fh " " x 93;                # Preencher com espaços em branco.
            print $fh "\r\n";

            $writeHeader = 0;
        }

        # Tratando os dados da doação.
        $receipt_id                    = left_padding_zeros($receipt_id, 21);
        my $payment_gateway_code       = $donation->payment_gateway_code;
        $payment_gateway_code          =~ s/-//g;
        my ($doc_number, $auth_number) = unpack "(A16)*", $payment_gateway_code;
        $doc_number                    = left_padding_zeros($doc_number, 20);
        $auth_number                   = left_padding_zeros($auth_number, 20);
        my $cpf                        = left_padding_zeros($donation->cpf, 11);
        my $name                       = left_padding_whitespaces($donation->name, 60);
        my $captured_at                = $donation->captured_at->strftime('%m%d%Y');
        my $amount                     = sprintf("%.2f", $donation->amount / 100);
        $amount                        =~ s/\.//;
        $amount                        = left_padding_zeros($amount, 18);

        print $fh "2";                  # Registro.
        print $fh $receipt_id;          # Id do recibo.
        print $fh $doc_number;          # Numero do documento.
        print $fh $auth_number;         # Numero do documento.
        print $fh "01";                 # Tipo da doação. TODO Duvida.
        print $fh "02";                 # Espécie do recurso: cartão de crédito.
        print $fh $cpf;                 # CPF do doador.
        print $fh "F";                  # Pessoa física.
        print $fh $captured_at;         # Data da doação.
        print $fh $amount;              # Valor da doação.

        # Fim da doação.
        print $fh "\r\n";

        $count++;
        $receipt_id++;
    }

    # Trailer.
    print $fh "3";                           # Registro.
    print $fh left_padding_zeros($count, 9); # Total de doações presentes neste arquivo.
    print $fh " " x 154;                     # Espaços em branco.

    return $fh;
}

1;

