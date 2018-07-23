package VotoLegal::Schema::ResultSet::VotolegalDonation;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'VotoLegal::Role::Verification';

use File::Slurper 'read_text';
use Email::Valid;
use Data::Verifier;
use Business::BR::CEP qw(test_cep);
use VotoLegal::Types qw(EmailAddress CPF PositiveInt CommonLatinText);
use VotoLegal::Utils;
use DateTime::Format::Pg;
use DateTime;
use FindBin qw($RealBin);
use JSON qw/to_json from_json/;
use MIME::Base64;
use Text::CSV;
use File::Temp ':seekable';
use Time::HiRes;
use Cwd qw(chdir);
use UUID::Tiny qw/is_uuid_string/;

my $lr_code_table;

sub resultset {
    my $self = shift;

    return $self->result_source->schema->resultset(@_);
}

sub verifiers_specs {
    my $self = shift;

    return {
        search => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                device_authorization_token_id => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        return is_uuid_string( $_[0]->get_value('device_authorization_token_id') );
                    },
                },
                donation_id => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        return is_uuid_string( $_[0]->get_value('donation_id') );
                    },
                },
            }
        ),
        search_by_certiface => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                certiface_token => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        return is_uuid_string( $_[0]->get_value('certiface_token') );
                    },
                },
                device_authorization_token_id => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        return is_uuid_string( $_[0]->get_value('device_authorization_token_id') );
                    },
                },
            }
        ),
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required   => 1,
                    max_length => 100,
                    min_length => 3,
                    type       => "Str",
                    post_check => sub {
                        my $nome = lc $_[0]->get_value('name');

                        # tira espaços duplicados
                        $nome =~ s/\s+/\ /go;

                        my $reg = qr/^[a-z\-'´]{3,29}\s[a-z\-'´\.]{1,29}(\s[a-z\-'´\.]{1,29})*$/;

                        # verifica se precisa tirar os acentos
                        if ( $nome !~ /$reg/io ) {
                            my $f = $self->result_source->schema->unaccent($nome);

                            $nome = lc $f->{unaccent};
                        }

                        # verifca se segue a logica aplicada pelo certiface
                        # com isso, nao aceitamos nomes estrangeiros
                        return $nome =~ /$reg/io ? 1 : 0;
                    },
                },
                email => {
                    required   => 1,
                    max_length => 100,
                    type       => EmailAddress,
                },
                cpf => {
                    required => 1,
                    type     => CPF,
                },
                amount => {
                    required   => 1,
                    type       => PositiveInt,
                    post_check => sub {
                        my $amount = $_[0]->get_value('amount');

                        return 0 if $amount < 100;

                        if ( $amount > 106400 ) {
                            return 0;
                        }

                        return 1;
                    },
                },
                phone => {
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $phone = $_[0]->get_value('phone');
                        return 1 if !$phone;
                        return $phone =~ m{^[0-9]{10,11}$};
                    },
                },
                address_street => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                address_house_number => {
                    required => 0,
                    type     => PositiveInt,
                },
                address_district => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                address_zipcode => {
                    required   => 0,
                    type       => "Str",
                    max_length => 9,
                    post_check => sub {
                        test_cep( $_[0]->get_value('address_zipcode') );
                    },
                },
                address_city => {
                    required   => 0,
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('address_city');
                        $self->resultset('City')->search( { name => $city } )->count;
                    },
                },
                address_state => {
                    required   => 0,
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('address_state');
                        $self->resultset('State')->search( { code => $state } )->count;
                    },
                },
                address_complement => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                birthdate => {
                    required   => 0,
                    max_length => 100,
                    type       => "Str",
                    post_check => sub {

                        my $date = $_[0]->get_value('birthdate');
                        return 1 if !$date;

                        return 0 if $date !~ /^(19|20)[0-9]{2}-[0-9]{2}-[0-9]{2}$/;

                        my $dt = eval { DateTime::Format::Pg->parse_datetime($date) };
                        return 0 if $@;

                        my $duration = DateTime->now->subtract_datetime($dt);

                        my $idade = $duration->in_units('years');

                        return 0 if $idade < 18 || $idade >= 100;

                        return 1;
                    },
                },
                billing_address_street => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                billing_address_house_number => {
                    required => 0,
                    type     => PositiveInt,
                },
                billing_address_district => {
                    required   => 0,
                    max_length => 100,
                    type       => 'Str',
                },
                billing_address_zipcode => {
                    required   => 0,
                    max_length => 9,
                    type       => "Str",
                    post_check => sub {
                        test_cep( $_[0]->get_value('billing_address_zipcode') );
                    },
                },
                billing_address_city => {
                    required   => 0,
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $city = $_[0]->get_value('billing_address_city');
                        $self->resultset('City')->search( { name => $city } )->count;
                    },
                },
                billing_address_state => {
                    required   => 0,
                    max_length => 100,
                    type       => 'Str',
                    post_check => sub {
                        my $state = $_[0]->get_value('billing_address_state');
                        $self->resultset('State')->search( { code => $state } )->count;
                    },
                },
                billing_address_complement => {
                    required   => 0,
                    max_length => 100,
                    type       => CommonLatinText,
                },
                ip_address => {
                    required => 1,
                    type     => "Str",
                },
                device_authorization_token_id => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        my $v = $_[0]->get_value('device_authorization_token_id');
                        $self->resultset('DeviceAuthorizationToken')->search( { id => $v, verified => 1 } )->count;
                    },
                },
                candidate_id => {
                    required => 1,
                    type     => PositiveInt,
                },
                user_agent_id => {
                    required => 1,
                    type     => "Int",
                },
                donation_fp => {
                    required => 1,

                    # 1 mb
                    max_length => 1024 * 1024,
                    type       => "Str",
                },
                payment_method => {
                    required   => 1,
                    type       => "Str",
                    post_check => sub {
                        $_[0]->get_value('payment_method') =~ /^(credit_card|boleto)$/;
                    },
                },
                referral_code => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $referral_code = $_[0]->get_value('referral_code');

                        my $referral = $self->resultset('Referral')->find_or_create(
                            {
                                candidate_id => $_[0]->get_value('candidate_id'),
                                code         => $referral_code
                            }
                        );

                        return 1 if $referral;
                    }
                }
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

            # deixa apenas numeros
            defined $values{$_} and $values{$_} =~ s/[^0-9]//go for qw/cpf address_zipcode billing_address_zipcode/;
            $values{$_} = lc $values{$_} for qw/email/;

            my $candidate = $self->result_source->schema->resultset("Candidate")->find( $values{candidate_id} );

            if ( $candidate->name eq 'PARTIDO SOCIALISMO E LIBERDADE' ) {
                $values{$_} or die_with 'need_billing_adddress' for qw/
                  billing_address_street
                  billing_address_district
                  billing_address_zipcode
                  billing_address_city
                  billing_address_state
                  /;

                $values{$_} or die_with 'need_phone_for_psol'     for qw/phone/;
                $values{$_} or die_with 'need_birthdate_for_psol' for qw/birthdate/;
            }

            if ( $values{payment_method} eq 'boleto' ) {
                $values{$_} or die_with 'need_billing_adddress' for qw/
                  billing_address_street
                  billing_address_district
                  billing_address_house_number
                  billing_address_zipcode
                  billing_address_city
                  billing_address_state
                  /;

                if ( $candidate->emaildb_config_id != 2 ) {
                    $values{$_} or die_with 'need_phone_for_boleto'     for qw/phone/;
                    $values{$_} or die_with 'need_birthdate_for_boleto' for qw/birthdate/;
                }
            }

            # tira espaços duplicados antes de salvar
            $values{name} =~ s/\s+/\ /go;

            $self->_refuse_duplicate( map { $_ => $values{$_} } qw/cpf amount candidate_id/ );
            my $config = $self->_get_candidate_config( candidate_id => $values{candidate_id} );

            $self->_check_daily_limit(
                max_donation_value => $config->{max_donation_value},
                map { $_ => $values{$_} } qw/cpf amount candidate_id/
            );

            my $fingerprint = $self->validate_donation_fp( $values{donation_fp} );

            my $addr;

            # dominios comuns não precisa verificar o mx
            if (   is_test()
                || lc $values{email} =~ /\@(gmail|hotmail|icloud|outlook|msn|live|globo)\.com$/
                || lc $values{email} =~ /\@(terra|uol|yahoo|outlook|bol)\.com\.br$/ ) {
                $addr = $values{email};
            }
            else {
                eval { $addr = Email::Valid->address( -address => $values{email}, -mxcheck => 1 ) };
                die_with_reason 'email_invalid', "$@" if $@;
            }
            die_with 'email_domain_invalid' unless $addr;

            $values{email} = $addr;

            die_with 'amount_invalid' if $values{amount} < $config->{min_donation_value};

            my $donation = $self->_create_donation( config => $config, values => \%values, fp => $fingerprint );

            $donation->upsert_decred_data();

            return $donation;
        },

        search_by_certiface => sub {
            my $r = shift;

            my %values = $r->valid_values;

            my $donation = $self->search(
                {
                    'certiface_tokens.id'         => $values{certiface_token},
                    device_authorization_token_id => $values{device_authorization_token_id},
                },
                {
                    join    => 'certiface_tokens',
                    columns => ['me.id']
                }
            )->next;
            die_with 'donation-not-found' unless $donation;

            return $donation;
        },
        search => sub {
            my $r = shift;

            my %values = $r->valid_values;

            my $donation = $self->search(
                {
                    id                            => $values{donation_id},
                    device_authorization_token_id => $values{device_authorization_token_id},
                }
            )->next;
            die_with 'donation-not-found' unless $donation;

            return $donation;
        },
    };
}

sub validate_donation_fp {
    my ( $self, $fp ) = @_;

    $fp = eval { decode_base64($fp) };
    die_with 'fp-invalid-contact-support' if !$fp || $fp !~ /^{/ || $fp !~ /}$/;

    $fp = eval { from_json($fp) };
    if ( $fp->{id} ne 'error' ) {
        die_with 'fp-invalid-contact-support' if !$fp->{ms} || !$fp->{id};

        for (qw/ms canvas webgl/) {
            die_with 'fp-invalid-contact-support' if exists $fp->{$_} && $fp->{$_} !~ /^[0-9]+$/;
        }
    }

    return $fp;
}

sub _create_donation {
    my ( $self, %opts ) = @_;

    die 'transaction_depth is wrong' if !is_test && $self->result_source->storage->transaction_depth > 0;

    my %values    = %{ $opts{values} };
    my $config    = $opts{config};
    my $is_boleto = $values{payment_method} eq 'boleto';
    my $schema    = $self->result_source->schema;

    eval { $self->resultset('CpfLock')->find_or_create( { cpf => $values{cpf} } ) };

    my $donation;
    $schema->txn_do(
        sub {
            my $fp = $self->resultset('DonationFp')->create(
                {
                    user_agent_id => $values{user_agent_id},
                    fp_hash       => delete $opts{fp}{id},
                    ms            => ( delete $opts{fp}{ms} || 0 ),
                    canvas_result => delete $opts{fp}{canvas},
                    webgl_result  => delete $opts{fp}{webgl},
                }
            );

            while ( my ( $key, $value ) = each %{ $opts{fp} } ) {

                my $key_id = $self->resultset('DonationFpKey')->find_or_create( { key => $key } );
                my $value_id = $self->resultset('DonationFpValue')->find_or_create( { value => $value } );

                $self->resultset('DonationFpDetail')->create(
                    {
                        donation_fp_id       => $fp->id,
                        donation_fp_key_id   => $key_id->id,
                        donation_fp_value_id => $value_id->id
                    }
                );

            }

            $donation = $self->create(
                {
                    is_boleto => $is_boleto ? 1 : 0,
                    candidate_id                  => $values{candidate_id},
                    device_authorization_token_id => $values{device_authorization_token_id},
                    is_pre_campaign               => $config->{is_pre_campaign} ? 1 : 0,
                    payment_gateway_id            => $config->{payment_gateway_id},

                    votolegal_fp => $fp->id,

                    created_at => is_test() ? \'clock_timestamp()' : 'now()',
                }
            );

            my $donation_immu = $donation->new_related(
                'votolegal_donation_immutable',
                {
                    donation_type_id => $config->{donation_type_id},
                    amount           => $values{amount},

                    donor_name      => $values{name},
                    donor_email     => $values{email},
                    donor_cpf       => $values{cpf},
                    donor_phone     => $values{phone},
                    donor_birthdate => $values{birthdate},

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

                    referral_code => $values{referral_code},

                    started_ip_address => $values{ip_address},

                    git_hash => get_git_hash(),
                }
            )->insert;
        }
    );

    $donation->discard_changes;

    return $donation;
}

sub get_git_hash {
    chdir $RealBin;
    my $git_hash = `git rev-parse HEAD`;
    $git_hash =~ s/^\s+|\s+$//g;

    return $git_hash;
}

sub _get_candidate_config {
    my ( $self, %opts ) = @_;

    my $candidate = $self->result_source->schema->resultset('Candidate')->find( $opts{candidate_id} ) or die 'error';

    return {
        donation_type_id   => 1,                                                      #PF
        is_pre_campaign    => $candidate->campaign_donation_type eq 'pre-campaign',
        payment_gateway_id => 3,

        min_donation_value => $candidate->min_donation_value,
        max_donation_value => $candidate->campaign_donation_type eq 'party' ? 106400 : 106400,
    };

}

sub _refuse_duplicate {
    my ( $self, %values ) = @_;

    # Buscando uma possível doação repetida. Se aconteceu há menos de 30sec, travamos o processo.
    my $repeatedDonation = $self->search(
        {
            candidate_id                             => $values{candidate_id},
            'votolegal_donation_immutable.donor_cpf' => $values{cpf},
            'votolegal_donation_immutable.amount'    => $values{amount},
            created_at                               => { ">=" => \"(now() - '30 seconds'::interval)" },
        },
        {
            join => 'votolegal_donation_immutable'

        }
    )->next;

    if ($repeatedDonation) {
        die_with 'donation-repeated';
    }
}

sub _check_daily_limit {
    my ( $self, %values ) = @_;

    # Buscando por todas doações deste dia, deste CPF para o candidato,
    # onde é cartão e está captured, ou
    my $sum_donation = $self->search(
        {
            candidate_id                             => $values{candidate_id},
            'votolegal_donation_immutable.donor_cpf' => $values{cpf},

            '-or' => [

                # todos boletos abertos
                { 'state' => 'waiting_boleto_payment' },

                {
                    '-and' => [

                        # converte ambas para America/Sao_Paulo
                        \" timezone('America/Sao_Paulo', timezone('UTC', me.captured_at))::date = timezone('America/Sao_Paulo', now())::date",
                    ],

                }
            ]
        },
        {
            join => 'votolegal_donation_immutable'

        }
    )->get_column('votolegal_donation_immutable.amount')->sum();

    $sum_donation ||= 0;
    $sum_donation += $values{amount};

    if ( $sum_donation && $sum_donation > $values{max_donation_value} ) {
        die_with 'donation-daily-reached';
    }

}

sub sync_julios_payments {
    my ( $self, %opts ) = @_;

    my $rs = $self->search(
        {
            julios_next_check              => { '<=' => \'now()' },
            'candidate.split_rule_id'      => { '!=' => undef },
            'candidate.julios_customer_id' => { '!=' => undef },
        },
        {
            rows     => 30,
            join     => 'candidate',
        }
    );

    while ( my $r = $rs->next ) {

        eval { $r->sync_julios() };
        if ($@) {
            $r->discard_changes;
            $r->update( { julios_erromsg => $@, julios_next_check => \"julios_next_check + '5 minutes'::interval" } );
        }
    }

}

sub sync_pending_payments {
    my ( $self, %opts ) = @_;

    my $rs = $self->search(
        {
            next_gateway_check => { '<=' => \'now()' },
        },
        {
            rows     => 10,
        }
    );

    while ( my $r = $rs->next ) {

        my $interface = $self->result_source->schema->resultset('FsmState')->interface(
            class    => 'payment',
            loc      => $opts{loc},
            donation => $r,

            supports => {},
        );

    }
}

sub export_tse {
    my ( $self, $receipt_id ) = @_;

    my $fh = File::Temp->new( UNLINK => 1 );
    $fh->autoflush(1);

    $self->count or die \[ 'date', "no donations" ];

    my $count       = 0;
    my $writeHeader = 1;
    while ( my $donation = $self->next() ) {

        my $candidate      = $donation->candidate;
        my $candidate_url  = $ENV{VOTOLEGAL_FRONT_URL} . '/em/' . $candidate->username;
        my $candidate_cnpj = $candidate->cnpj;

        $candidate_cnpj =~ s/\D+//g;
        $candidate_cnpj = left_padding_zeros( $candidate_cnpj, 14 );

        my $data_movimentacao = DateTime->now( time_zone => "America/Sao_Paulo" )->strftime("%d%m%Y%H%M");
        my $bank_code           = left_padding_zeros( $donation->candidate->bank_code,           3 );
        my $bank_agency         = left_padding_zeros( $donation->candidate->bank_agency,         8 );
        my $bank_agency_dv      = left_padding_zeros( $donation->candidate->bank_agency_dv,      2 );
        my $bank_account_number = left_padding_zeros( $donation->candidate->bank_account_number, 18 );
        my $bank_account_dv     = left_padding_zeros( $donation->candidate->bank_account_dv,     2 );

        # Escrevendo o header.
        if ($writeHeader) {
            print $fh "1";                                               # Registro.
            print $fh '30217474000150';                                  # CNPJ.
            print $fh "PAGUE JUNTO TECNOLOGIA DE INTERMEDIACAO LTDA";    # Nome fantasia.
            print $fh " " x 56;                                          # Preencher com espaços em branco.
            print $fh '100';                                             # Versão do layout.
            print $fh 'ATSEFCC';                                         # Nome do layout.
            print $fh " " x 247;                                         # Preencher com espaços em branco.
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

        # TODO
        # A url provavelmente será modificada para uma URL específica da doação
        $candidate_url = right_padding_whitespaces( $candidate_url, ( 255 - length $candidate_url ) );

        print $fh "2";                # Registro.
        print $fh $candidate_cnpj;    # CNPJ.
        print $fh $candidate_url;     # Página web.
        print $fh $receipt_id;        # Id do recibo.
        print $fh $doc_number;        # Numero do documento.
        print $fh $auth_number;       # Numero do documento.
        print $fh "01";               # Tipo da doação. TODO Duvida.
        print $fh "02";               # Espécie do recurso: cartão de crédito.
        print $fh $cpf;               # CPF do doador.
        print $fh "F";                # Pessoa física.
        print $fh $captured_at;       # Data da doação.
        print $fh $amount;            # Valor da doação.

        # Fim da doação.
        print $fh "\r\n";

        $count++;
        $receipt_id++;
    }

    # Trailer.
    print $fh "3";                    # Registro.
    print $fh left_padding_zeros( $count, 9 );    # Total de doações presentes neste arquivo.
    print $fh " " x 154;                          # Espaços em branco.

    return $fh;
}

sub _load_lr {
    my ($self) = @_;

    die 'Cannot find lr_code.json [$ENV{LR_CODE_JSON_FILE}]' unless -e $ENV{LR_CODE_JSON_FILE};

    $lr_code_table = from_json( read_text( $ENV{LR_CODE_JSON_FILE} ) );
}

sub _get_status_and_motive {
    my ( $self, $row ) = @_;

    my $state       = $row->{_state};
    my $lr          = $row->{_lr};
    my $is_refunded = $row->{_refunded_at};
    my $is_captured = $row->{_captured_at};

    if ( !$lr_code_table ) {
        $self->_load_lr();
    }

    my ( $status, $motive );

    if ($is_refunded) {
        $status = 'Estornada';
        $motive = 'Doador solicitou chargeback';
    }
    elsif ($is_captured) {
        $status = 'Autorizada';
        $motive = '';
    }
    elsif ( $state eq 'not_authorized' ) {
        $status = 'Negada';

        $motive = $lr_code_table->{$lr}[0] . ' - ' . $lr_code_table->{$lr}[1];
    }
    elsif ( $state =~ /waiting_boleto_payment|boleto_expired/ ) {
        $status = 'Pagamento não efetuado';

        $motive = 'Boleto aguardando pagamento' if $state eq 'waiting_boleto_payment';
        $motive = 'Boleto vencido' if $state eq 'boleto_expired';
    }
    else {

        $status = 'Doação não finalizada';

        if ( $state eq 'certificate_refused' ) {
            $motive = 'Reconhecimento facial negado';
        }
        elsif ( $state eq 'boleto_authentication' ) {
            $motive = 'Cadastro não finalizado';
        }
        elsif ( $state eq 'credit_card_form' ) {
            $motive = 'Aguardando informar cartão de crédito';
        }
        else {
            $motive = "Erro: " . $state;
        }
    }

    return ( $status, $motive );
}

sub get_non_finished_donations_on_last_3_days {
    my ( $self, $candidate_id ) = @_;

    my @where = \[ <<'SQL_QUERY', $candidate_id ];
      state IN ('credit_card_form', 'boleto_authetication')
      AND created_at BETWEEN ( now()::date - interval '3 days' ) AND ( now()::date - interval '2 days' )
      AND candidate_id = ?
      AND me.id = votolegal_donation_immutable.votolegal_donation_id
      AND NOT EXISTS (
          SELECT 1 FROM votolegal_donation_immutable, votolegal_donation
            WHERE donor_cpf = votolegal_donation_immutable.donor_cpf
                AND me.created_at >= now()::date - interval '3 days'
                AND me.id = votolegal_donation_immutable.votolegal_donation_id
      )
SQL_QUERY

    return $self->search( { '-and' => \@where }, { prefetch => 'votolegal_donation_immutable' } );
}

1;

