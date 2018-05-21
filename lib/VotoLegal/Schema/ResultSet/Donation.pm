package VotoLegal::Schema::ResultSet::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

use Text::CSV;
use File::Temp ':seekable';
use Time::HiRes;

use VotoLegal::Utils;

sub resultset {
    my $self = shift;

    return $self->result_source->schema->resultset(@_);
}

sub export {
    my ( $self, $receipt_id ) = @_;

    my $fh = File::Temp->new( UNLINK => 1 );
    $fh->autoflush(1);

    $self->count or die \[ 'date', "no donations" ];

    my $count       = 0;
    my $writeHeader = 1;
    while ( my $donation = $self->next() ) {

        # Tratando alguns campos do candidato.
        my $cnpj = $donation->candidate->cnpj;
        $cnpj =~ s/\D+//g;
        $cnpj = left_padding_zeros( $cnpj, 14 );
        my $data_movimentacao = DateTime->now( time_zone => "America/Sao_Paulo" )->strftime("%d%m%Y%H%M");
        my $bank_code           = left_padding_zeros( $donation->candidate->bank_code,           3 );
        my $bank_agency         = left_padding_zeros( $donation->candidate->bank_agency,         8 );
        my $bank_agency_dv      = left_padding_zeros( $donation->candidate->bank_agency_dv,      2 );
        my $bank_account_number = left_padding_zeros( $donation->candidate->bank_account_number, 18 );
        my $bank_account_dv     = left_padding_zeros( $donation->candidate->bank_account_dv,     2 );

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
        $receipt_id = left_padding_zeros( $receipt_id, 21 );
        my $payment_gateway_code = $donation->payment_gateway_code;
        $payment_gateway_code =~ s/-//g;
        my ( $doc_number, $auth_number ) = unpack "(A16)*", $payment_gateway_code;
        $doc_number  = left_padding_zeros( $doc_number,  20 );
        $auth_number = left_padding_zeros( $auth_number, 20 );
        my $cpf = left_padding_zeros( $donation->cpf, 11 );
        my $name        = left_padding_whitespaces( $donation->name, 60 );
        my $captured_at = $donation->captured_at->strftime('%m%d%Y');
        my $amount      = sprintf( "%.2f", $donation->amount / 100 );
        $amount =~ s/\.//;
        $amount = left_padding_zeros( $amount, 18 );

        print $fh "2";             # Registro.
        print $fh $receipt_id;     # Id do recibo.
        print $fh $doc_number;     # Numero do documento.
        print $fh $auth_number;    # Numero do documento.
        print $fh "01";            # Tipo da doação. TODO Duvida.
        print $fh "02";            # Espécie do recurso: cartão de crédito.
        print $fh $cpf;            # CPF do doador.
        print $fh "F";             # Pessoa física.
        print $fh $captured_at;    # Data da doação.
        print $fh $amount;         # Valor da doação.

        # Fim da doação.
        print $fh "\r\n";

        $count++;
        $receipt_id++;
    }

    # Trailer.
    print $fh "3";                 # Registro.
    print $fh left_padding_zeros( $count, 9 );    # Total de doações presentes neste arquivo.
    print $fh " " x 154;                          # Espaços em branco.

    return $fh;
}

1;

