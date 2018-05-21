#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../../lib";

use VotoLegal::SchemaConnected;

use Email::Sender;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP qw();
use Try::Tiny;

my $schema = get_schema;

my @rows;
my $csv = Text::CSV->new( { binary => 1 } ) or die "Cannot use CSV: " . Text::CSV->error_diag();

$csv->eol("\r\n");

open my $fh, ">:encoding(utf8)", "report.csv" or die " report.csv: $!";

# header
$csv->print(
    $fh,
    [
        'status da conta', 'data de pagamento', 'cod. do pagamento', 'metodo',
        'nome',            'email',             'cargo',             'partido',
        'movimento',       'nome do pagamento', 'telefone',          'estado',
        'cidade',          'cep',               'rua',               'numero',
        'complemento',     'valor bruto',       'taxa',              'valor liquido'
    ]
);

my $candidates = $schema->resultset("Candidate")->get_candidates_with_data_for_admin();

while ( my $candidate = $candidates->next() ) {
    my $row = [];

    my $payment = $candidate->get_most_recent_payment();

    my $payment_status = $candidate->get_account_payment_status();

    my $col_1  = $payment_status;
    my $col_2  = $payment ? $payment->created_at : 0;
    my $col_3  = $payment ? $payment->code : 0;
    my $col_4  = $payment ? $payment->get_human_like_method() : 0;
    my $col_5  = $candidate->name;
    my $col_6  = $candidate->user->email;
    my $col_7  = $candidate->office->name;
    my $col_8  = $candidate->party->name;
    my $col_9  = $candidate->political_movement_id ? $candidate->political_movement->name : 0;
    my $col_10 = $payment ? $payment->name : 0;
    my $col_11 = $payment ? $payment->phone : 0;
    my $col_12 = $candidate->address_state;
    my $col_13 = $candidate->address_city;
    my $col_14 = $candidate->address_zipcode;
    my $col_15 = $candidate->address_street;
    my $col_16 = $candidate->address_house_number;
    my $col_17 = $candidate->address_complement;
    my $col_18;
    my $col_19;
    my $col_20;

    if ( !$payment ) {
        $col_18 = 0;
        $col_19 = 0;
        $col_20 = 0;
    }
    else {
        my $payment_pagseguro_data = $payment->get_pagseguro_data();

        if ($payment_pagseguro_data) {
            $payment_pagseguro_data->{grossAmount} =~ s/\./,/g;
            $payment_pagseguro_data->{feeAmount} =~ s/\./,/g;
            $payment_pagseguro_data->{netAmount} =~ s/\./,/g;

            $col_18 = $payment_pagseguro_data->{grossAmount};
            $col_19 = $payment_pagseguro_data->{feeAmount};
            $col_20 = $payment_pagseguro_data->{netAmount};
        }
        else {
            $col_18 = 0;
            $col_19 = 0;
            $col_20 = 0;
        }

    }

    $row = [
        $col_1,  $col_2,  $col_3,  $col_4,  $col_5,  $col_6,  $col_7,  $col_8,  $col_9,  $col_10,
        $col_11, $col_12, $col_13, $col_14, $col_15, $col_16, $col_17, $col_18, $col_19, $col_20
    ];
    push @rows, $row;
}

$csv->print( $fh, $_ ) for @rows;

close $fh or die "report.csv: $!";

my $message = Email::MIME->create(
    attributes => {
        filename     => "report.csv",
        content_type => "application/csv",
        encoding     => "quoted-printable",
        name         => "report.csv",
    },
);

my $transport = Email::Sender::Transport::SMTP->new(
    {
        host     => $ENV{EMAIL_SMTP_SERVER},
        port     => $ENV{EMAIL_SMTP_PORT},
        username => $ENV{EMAIL_SMTP_USERNAME},
        password => $ENV{EMAIL_SMTP_PASSWORD},
    }
);

try {
    sendmail(
        $message,
        {
            from      => $ENV{EMAIL_DEFAULT_FROM},
            to        => 'lucas.ansei@eokoe.com',
            transport => $transport
        }
    );
}
catch {
    warn "sending failed: $_";
};
