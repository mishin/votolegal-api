package VotoLegal::Test::Further;
use common::sense;
use FindBin qw($RealBin);
use Carp;

use Test::More;
use Catalyst::Test q(VotoLegal);
use CatalystX::Eta::Test::REST;

use Text::Lorem;
use Config::General;
use Data::Printer;
use JSON::MaybeXS;
use Crypt::PRNG qw(random_string);
use Business::BR::CPF qw(random_cpf);
use Business::BR::CNPJ qw(random_cnpj format_cnpj);
use Data::Fake qw(Core Company Dates Internet Names Text);

our $iugu_invoice_response;
our $iugu_invoice_response_capture;

our $certiface_generate_token;
our $certiface_get_token_information;

# ugly hack
sub import {
    strict->import;
    warnings->import;

    no strict 'refs';

    my $caller = caller;

    while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } ) {
        next if $name eq 'BEGIN';     # don't export BEGIN blocks
        next if $name eq 'import';    # don't export this sub
        next unless *{$symbol}{CODE}; # export subs only

        my $imported = $caller . '::' . $name;
        *{$imported} = \*{$symbol};
    }
}

my $current_ua = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/51.0.2704.103 Safari/' . rand;
my $obj        = CatalystX::Eta::Test::REST->new(
    do_request => sub {
        my $req = shift;

        $req->header( 'User-Agent' => $current_ua );

        eval 'do{my $x = $req->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        my ( $res, $c ) = ctx_request($req);
        eval 'do{my $x = $res->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        return $res;
    },
    decode_response => sub {
        my $res = shift;
        return undef unless $res->content;
        return decode_json( $res->content );
    }
);

for (qw/rest_get rest_put rest_head rest_delete rest_post rest_reload rest_reload_list/) {
    eval( 'sub ' . $_ . ' { return $obj->' . $_ . '(@_) }' );
}

sub stash_test ($&) {
    $obj->stash_ctx(@_);
}

sub stash ($) {
    $obj->stash->{ $_[0] };
}

sub test_instance { $obj }

sub db_transaction (&) {
    my ( $subref, $modelname ) = @_;

    my $schema = VotoLegal->model( $modelname || 'DB' );

    eval {
        $schema->txn_do(
            sub {
                $subref->($schema);
                die 'rollback';
            }
        );
    };
    die $@ unless $@ =~ /rollback/;
}

my $auth_user = {};

sub api_auth_as {
    my (%conf) = @_;

    if ( !exists( $conf{user_id} ) && !exists( $conf{candidate_id} ) && !exists( $conf{nobody} ) ) {
        croak "api_auth_as: missing 'user_id', 'candidate_id' or 'nobody'.";
    }

    if ( exists( $conf{nobody} ) ) {
        $obj->fixed_headers( [] );
        return;
    }

    my $user_id      = $conf{user_id};
    my $candidate_id = $conf{candidate_id};

    my $schema = VotoLegal->model( defined( $conf{model} ) ? $conf{model} : 'DB' );

    if ( defined($candidate_id) ) {
        $user_id = $schema->resultset('Candidate')->find($candidate_id)->user_id;
    }

    if ( $auth_user->{id} != $user_id ) {
        my $user = $schema->resultset('User')->find($user_id);

        croak 'api_auth_as: user not found' unless $user;

        my $session = $user->new_session( ip => "127.0.0.1" );

        $auth_user = {
            id      => $user_id,
            api_key => $session->{api_key},
        };
    }

    $obj->fixed_headers( [ 'x-api-key' => $auth_user->{api_key} ] );
}

sub create_candidate {
    my (%opts) = @_;

    my $name     = fake_name()->();
    my $username = lc $name;
    $username =~ s/\s+/_/g;

    my %params = (
        username             => $username,
        password             => "foobarquux1",
        name                 => fake_name()->(),
        popular_name         => fake_surname()->(),
        email                => fake_email()->(),
        cpf                  => random_cpf(),
        address_state        => 'SP',
        address_city         => 'Iguape',
        address_zipcode      => '11920-000',
        address_street       => "Rua Tiradentes",
        address_house_number => 1 + int( rand(2000) ),
        office_id            => 4,
        birth_date           => '11/05/1998',
        party_id             => fake_int( 1, 35 )->(),
        reelection           => fake_int( 0, 1 )->(),
        %opts,
    );

    return $obj->rest_post(
        '/api/register',
        name  => 'add candidate',
        stash => 'candidate',
        [%params],
    );
}

sub lorem_words {
    my ($words) = @_;

    my $lorem = Text::Lorem->new();

    return $lorem->words( $words || 5 );
}

sub lorem_paragraphs {
    my ($n) = @_;

    my $lorem = Text::Lorem->new();

    return $lorem->paragraphs( $n || 3 );
}

sub get_config {
    my $conf   = new Config::General("$RealBin/../../votolegal.conf");
    my %config = $conf->getall;

    return \%config;
}

sub error_is ($$) {
    my ( $stash_name, $error_exp ) = @_;

    is $obj->stash->{$stash_name}{error}, $error_exp, "$stash_name is $error_exp";

}

sub create_candidate_contract_signature {
    my ($candidate_id) = @_;

    return $obj->rest_post(
        "/api/candidate/$candidate_id/contract_signature",
        name                => 'add candidate contract signature',
        stash               => 'contract_signature',
        automatic_load_item => 0
    );
}

sub generate_device_token {

    my $res = $obj->rest_post(
        "/api2/device-authentication",
        name    => 'generate_device_token',
        code    => 200,
    );

    $obj->{stash}{test_auth} = $res->{device_authorization_token_id};
}

sub generate_rand_donator_data {
    my $info = fake_hash(
        {
            name  => fake_name(),
            email => fake_email(),

            birthdate => '2000-01-01',

            #address_district             => "Centro",
            #address_state                => fake_pick(qw(SP RJ MG RS PR)),
            #address_city                 => "Iguape",
            #address_street               => "Rua Tiradentes",
            #address_zipcode              => "11920-000",
            #address_house_number         => fake_int( 1, 1000 )->(),

            billing_address_house_number => fake_int( 1, 1000 )->(),
            billing_address_district     => "Centro",
            billing_address_city         => "Iguape",
            billing_address_state        => "SP",
            billing_address_street       => "Rua Tiradentes",
            billing_address_zipcode      => "11920-000",
            phone                        => fake_digits("##########")->(),
        }
    )->();

    return wantarray ? %$info : $info;
}

our $sessionkey;

sub set_current_dev_auth {
    $sessionkey = shift;
}

sub get_current_stash () {
    my $schema = VotoLegal->model('DB');

    my $row = $schema->resultset('DeviceSession')->search( { device_authorization_token_id => $sessionkey } )->next;
    if ($row) {
        return decode_json( $row->stash );
    }
    return undef;
}

sub messages2str ($) {
    my ($where) = @_;

    ( join ' ', map { $_->{text} } grep { $_->{type} eq 'msg' } @{ $where->{ui}{messages} || [] } );
}

sub buttons2str ($) {
    my ($where) = @_;

    (
        join ' ',
        map { $_->{text} . '-' . $_->{value} } grep { $_->{type} eq 'button' } @{ $where->{ui}{messages} || [] }
    );
}

sub links2str ($) {
    my ($where) = @_;

    ( join ' ', map { $_->{text} } grep { $_->{type} eq 'link' } @{ $where->{ui}{messages} || [] } );
}

sub form2str ($) {
    my ($where) = @_;

    ( join ' ', map { $_->{ref} } grep { $_->{type} =~ /form/ } @{ $where->{ui}{messages} || [] } );
}

sub assert_current_step ($) {
    my ($stepname) = @_;
    my $schema = VotoLegal->model('DB');

    my $row = $schema->resultset('VotolegalDonation')->search( { device_authorization_token_id => $sessionkey } )->next;
    if ($row) {
        unless ( is( $row->state, $stepname, "current state is $stepname" ) ) {
            my $str = 'Real fail is on' . ( join " - ", caller() ) . "\n\n";
            print STDERR $str;
            exit(1);
        }
    }
}

sub setup_mock_certiface {
    $certiface_generate_token = {
        url => 'https://site.domain.br/certifacetoken/dd24700e-2855-4e0c-81db-53ddc14a44ec',
        id  => 'dd24700e-2855-4e0c-81db-53ddc14a44ec'
    };

    $certiface_get_token_information = {
        "token"         => "dd24700e-2855-4e0c-81db-53ddc14a44ec",
        "cpf"           => 15859607059,
        "nome"          => "Delilah Yaritza Flowers",
        "nascimento"    => "1999-12-31",
        "telefone"      => "3633784957",
        "status"        => 0,
        "resultado"     => 0,
        "dataExpiracao" => "2018-05-17 05:02:55",
        "resultados"    => undef
    };
}

sub setup_mock_certiface_success {

    $certiface_get_token_information = {
        "token"         => "dd24700e-2855-4e0c-81db-53ddc14a44ec",
        "cpf"           => 15859607059,
        "nome"          => "Delilah Yaritza Flowers",
        "nascimento"    => "1999-12-31",
        "telefone"      => "3633784957",
        "status"        => 1,
        "resultado"     => 1,
        "dataExpiracao" => "2018-05-17 05:02:55",
        "resultados"    => [
            {
                "protocolo" => "201800012443",
                "cause"     => "BIOMETRIA",
                "valid"     => 0
            },
            {
                "protocolo" => "201800012437",
                "cause"     => undef,
                "valid"     => 1
            }
        ]
    };
}

sub setup_mock_certiface_fail {

    $certiface_get_token_information = {
        "token"         => "dd24700e-2855-4e0c-81db-53ddc14a44ec",
        "cpf"           => 15859607059,
        "nome"          => "Delilah Yaritza Flowers",
        "nascimento"    => "1999-12-31",
        "telefone"      => "3633784957",
        "status"        => 1,
        "resultado"     => 1,
        "dataExpiracao" => "2018-05-17 05:02:55",
        "resultados"    => [
            {
                "protocolo" => "201800012441",
                "cause"     => "PROVA DE VIDA",
                "valid"     => 0
            },
            {
                "protocolo" => "201800012440",
                "cause"     => "IMAGEM [Posicionamento não frontal]",
                "valid"     => 0
            },
            {
                "protocolo" => "201800012442",
                "cause"     => "PROVA DE VIDA",
                "valid"     => 0
            }
        ]
    };
}

sub setup_sucess_mock_iugu {

    $iugu_invoice_response = {
        advance_fee       => undef,
        advance_fee_cents => undef,
        bank_slip         => undef,
        cc_emails         => undef,
        _charge_response_ => {
            errors         => {},
            identification => undef,
            invoice_id     => "688E8415E2D744C0BA819F6BC1D2092C",
            LR             => "00",
            message        => "Autorizado",
            pdf            => "https://faturas.iugu.com/688e8415-e2d7-44c0-ba81-9f6bc1d2092c-9adb.pdf",
            success        => \1,
            url            => "https://faturas.iugu.com/688e8415-e2d7-44c0-ba81-9f6bc1d2092c-9adb"
        },
        commission                    => "R\$ 0,00",
        commission_cents              => undef,
        created_at                    => "12/05, 14:36 h",
        created_at_iso                => "2018-05-12T14:36:14-03:00",
        currency                      => "BRL",
        customer_id                   => undef,
        customer_name                 => undef,
        customer_ref                  => undef,
        custom_variables              => [],
        discount                      => undef,
        discount_cents                => undef,
        due_date                      => "2018-05-17",
        early_payment_discount        => \0,
        early_payment_discounts       => [],
        email                         => "1b7f9734-f24c-4c52-935e-c7fe4af78386\@no-email.com",
        financial_return_date         => undef,
        financial_return_dates        => undef,
        fines_on_occurrence_day       => undef,
        fines_on_occurrence_day_cents => undef,
        id                            => "688E8415E2D744C0BA819F6BC1D2092C",
        ignore_canceled_email         => undef,
        ignore_due_email              => undef,
        installments                  => undef,
        interest                      => undef,
        items                         => [
            {
                created_at  => "2018-05-12T14:36:14-03:00",
                description => "Doação para pre-campanha Conley CPF 25991717923",
                id          => "E16AEC8787B844469C56F20C0C5144E8",
                price       => "R\$ 30,00",
                price_cents => 3000,
                quantity    => 1,
                updated_at  => "2018-05-12T14:36:14-03:00"
            }
        ],
        items_total_cents => 3000,
        logs              => [
            {
                created_at  => "12/05, 14:36 h",
                description => "Email de Lembrete enviado!",
                id          => "FB5AB9BB478F4DAA996DCF7891522AA4",
                notes       => "Lembrete enviado com sucesso para: 1b7f9734-f24c-4c52-935e-c7fe4af78386\@no-email.com"
            }
        ],
        notification_url              => undef,
        occurrence_date               => undef,
        overpaid_cents                => undef,
        paid                          => "R\$ 0,00",
        paid_at                       => undef,
        paid_cents                    => undef,
        payable_with                  => "credit_card",
        payment_method                => undef,
        refundable                    => undef,
        return_url                    => undef,
        secure_id                     => "688e8415-e2d7-44c0-ba81-9f6bc1d2092c-9adb",
        secure_url                    => "https://faturas.iugu.com/688e8415-e2d7-44c0-ba81-9f6bc1d2092c-9adb",
        status                        => "pending",
        tax_cents                     => undef,
        taxes_paid                    => "R\$ 0,00",
        taxes_paid_cents              => undef,
        total                         => "R\$ 30,00",
        total_cents                   => 3000,
        total_on_occurrence_day       => undef,
        total_on_occurrence_day_cents => undef,
        total_overpaid                => "R\$ 0,00",
        total_paid                    => "R\$ 0,00",
        total_paid_cents              => 0,
        transaction_number            => 1111,
        updated_at                    => "2018-05-12T14:36:14-03:00",
        updated_at_iso                => "2018-05-12T14:36:14-03:00",
        user_id                       => undef,
        variables                     => [
            {
                id       => "B883534D6E2C43C4802EB56AEE442F78",
                value    => "Iguape",
                variable => "payer.address.city"
            },
            {
                id       => "F313AB046939443996099499245DE18F",
                value    => "Centro",
                variable => "payer.address.district"
            },
            {
                id       => "887E691DC9C64B32815BE03B403477BD",
                value    => 419,
                variable => "payer.address.number"
            },
            {
                id       => "CE862B059E6F4692981DF694D6A3CABD",
                value    => "SP",
                variable => "payer.address.state"
            },
            {
                id       => "E3A8874151B64325B5C269887A6073E8",
                value    => "Rua Tiradentes",
                variable => "payer.address.street"
            },
            {
                id       => "C459FF174A794C338D41A8590E8DD083",
                value    => "11920-000",
                variable => "payer.address.zip_code"
            },
            {
                id       => "951AB9DE8E104F35AFCE88270EA8F302",
                value    => 46223869762,
                variable => "payer.cpf_cnpj"
            },
            {
                id       => "288E352ADD3F439F95F13DA9EF283F90",
                value    => "Ashlynn Destinee Sullivan",
                variable => "payer.name"
            },
            {
                id       => "7EC745F3EA194132974AB2B9240A918B",
                value    => 1111,
                variable => "payment_data.transaction_number"
            }
        ]
    };

    $iugu_invoice_response_capture = {
        'early_payment_discount' => \0,
        'updated_at_iso'         => '2018-05-14T11:06:38-03:00',
        'currency'               => 'BRL',
        'total_overpaid'         => '0.00 BRL',
        'logs'                   => [
            {
                'id'          => 'A0BB0AA5FAB8449BA4B7F3724420F716',
                'description' => 'Receipt email sent!',
                'notes'       => 'Successfully sent receipt to: 1b7f9734-f24c-4c52-935e-c7fe4af78386@no-email.com',
                'created_at'  => '14 May 11:06'
            },
            {
                'created_at'  => '14 May 11:06',
                'notes'       => 'Invoice paid using credit card by:  , , , LR: 00',
                'description' => 'Invoice successfully paid!',
                'id'          => '2A5323DB34FE4BB5B5CAD5B542FB1329'
            },
            {
                'id'          => 'E157E8D4D23949B69BEC4B78BD514ED9',
                'description' => 'Invoice viewed!',
                'notes'       => 'Invoice viewed!  ',
                'created_at'  => '14 May 10:17'
            },
            {
                'description' => 'Invoice viewed!',
                'id'          => '3C53076E0F574822A959813435744166',
                'created_at'  => '12 May 14:40',
                'notes'       => 'Invoice viewed!  '
            },
            {
                'description' => 'Payment authorized!',
                'id'          => '3F3311C1884F437B8E41A6349D8CA0F7',
                'created_at'  => '12 May 14:36',
                'notes'       => 'Payment authorized using credit card by: LR: 00'
            },
            {
                'created_at'  => '12 May 14:36',
                'notes'       => 'Successfully sent reminder to: 1b7f9734-f24c-4c52-935e-c7fe4af78386@no-email.com',
                'description' => 'Reminder email sent!',
                'id'          => 'FB5AB9BB478F4DAA996DCF7891522AA4'
            }
        ],
        'created_at_iso'   => '2018-05-12T14:36:14-03:00',
        'commission_cents' => 0,
        'payment_method'   => 'iugu_credit_card_test',
        'overpaid_cents'   => undef,
        'items'            => [
            {
                'description' => "Doaçao para pre-campanha Conley CPF 25991717923",
                'quantity'    => 1,
                'id'          => 'E16AEC8787B844469C56F20C0C5144E8',
                'price'       => '30.00 BRL',
                'created_at'  => '2018-05-12T14:36:14-03:00',
                'updated_at'  => '2018-05-12T14:36:14-03:00',
                'price_cents' => 3000
            }
        ],
        'taxes_paid'              => '0.75 BRL',
        'due_date'                => '2018-05-17',
        'customer_id'             => undef,
        'cc_emails'               => undef,
        'id'                      => '688E8415E2D744C0BA819F6BC1D2092C',
        'early_payment_discounts' => [],
        'bank_slip'               => undef,
        'variables'               => [
            {
                'id'       => 'B883534D6E2C43C4802EB56AEE442F78',
                'variable' => 'payer.address.city',
                'value'    => 'Iguape'
            },
            {
                'value'    => 'Centro',
                'variable' => 'payer.address.district',
                'id'       => 'F313AB046939443996099499245DE18F'
            },
            {
                'value'    => '419',
                'variable' => 'payer.address.number',
                'id'       => '887E691DC9C64B32815BE03B403477BD'
            },
            {
                'value'    => 'SP',
                'variable' => 'payer.address.state',
                'id'       => 'CE862B059E6F4692981DF694D6A3CABD'
            },
            {
                'variable' => 'payer.address.street',
                'value'    => 'Rua Tiradentes',
                'id'       => 'E3A8874151B64325B5C269887A6073E8'
            },
            {
                'value'    => '11920-000',
                'variable' => 'payer.address.zip_code',
                'id'       => 'C459FF174A794C338D41A8590E8DD083'
            },
            {
                'id'       => '951AB9DE8E104F35AFCE88270EA8F302',
                'value'    => '46223869762',
                'variable' => 'payer.cpf_cnpj'
            },
            {
                'variable' => 'payer.name',
                'value'    => 'Ashlynn Destinee Sullivan',
                'id'       => '288E352ADD3F439F95F13DA9EF283F90'
            },
            {
                'variable' => 'payment_data.arp',
                'value'    => '00000',
                'id'       => 'CF484150E1C8490C91D59B54316D134A'
            },
            {
                'value'    => '1',
                'variable' => 'payment_data.installments',
                'id'       => '0675D60A9DC54B3AB4890D7032286A7A'
            },
            {
                'value'    => '00000',
                'variable' => 'payment_data.nsu',
                'id'       => 'E0D9866AE2774D9CA4FC5512745FD155'
            },
            {
                'id'       => 'A8B688479BB14D9EAAC483949A4FC0BD',
                'value'    => '00000000000000000001',
                'variable' => 'payment_data.transaction_id'
            },
            {
                'id'       => '7EC745F3EA194132974AB2B9240A918B',
                'variable' => 'payment_data.transaction_number',
                'value'    => '1111'
            },
            {
                'id'       => '9231C0DCC59D4E9A8F6C1443E4160995',
                'variable' => 'payment_method',
                'value'    => 'iugu_credit_card_test'
            }
        ],
        'secure_id'                     => '688e8415-e2d7-44c0-ba81-9f6bc1d2092c-9adb',
        'financial_return_dates'        => undef,
        'financial_return_date'         => undef,
        'paid'                          => '30.00 BRL',
        'ignore_due_email'              => undef,
        'total_paid'                    => '30.00 BRL',
        'custom_variables'              => [],
        'installments'                  => '1',
        'interest'                      => undef,
        'advance_fee'                   => undef,
        'tax_cents'                     => undef,
        'created_at'                    => '12 May 14:36',
        'updated_at'                    => '2018-05-14T11:06:38-03:00',
        'status'                        => 'paid',
        'discount'                      => undef,
        'ignore_canceled_email'         => undef,
        'total_cents'                   => 3000,
        'user_id'                       => undef,
        'payable_with'                  => 'credit_card',
        'transaction_number'            => 1111,
        'commission'                    => '0.00 BRL',
        'customer_name'                 => undef,
        'refundable'                    => \1,
        'notification_url'              => undef,
        'total'                         => '30.00 BRL',
        'discount_cents'                => undef,
        'email'                         => '1b7f9734-f24c-4c52-935e-c7fe4af78386@no-email.com',
        'secure_url'                    => 'https://faturas.iugu.com/688e8415-e2d7-44c0-ba81-9f6bc1d2092c-9adb',
        'total_on_occurrence_day'       => '30.00 BRL',
        'total_paid_cents'              => 3000,
        'paid_at'                       => '2018-05-14T11:06:38-03:00',
        'fines_on_occurrence_day'       => '0.00 BRL',
        'customer_ref'                  => undef,
        'paid_cents'                    => 3000,
        'advance_fee_cents'             => undef,
        'taxes_paid_cents'              => 75,
        'total_on_occurrence_day_cents' => 3000,
        'fines_on_occurrence_day_cents' => 0,
        'items_total_cents'             => 3000,
        'return_url'                    => undef,
        'occurrence_date'               => '2018-05-14'
    };

}

sub setup_sucess_mock_iugu_boleto_success {

    $iugu_invoice_response = {
        'occurrence_date'               => '2018-05-14',
        'total_paid'                    => '35.00 BRL',
        'customer_ref'                  => undef,
        'customer_id'                   => undef,
        'ignore_canceled_email'         => undef,
        'total_on_occurrence_day_cents' => 3500,
        'total_cents'                   => 3500,
        'secure_url'                    => 'https://faturas.iugu.com/8ed8e2a0-ff4e-452b-b7b2-987699ab835d-afe8',
        'fines_on_occurrence_day_cents' => 0,
        'custom_variables'              => [],
        'total_paid_cents'              => 3500,
        'logs'                          => [
            {
                'created_at'  => '14 May 10:34',
                'notes'       => 'Invoice viewed!  ',
                'id'          => '30D1DCE059284874847A2937479D3539',
                'description' => 'Invoice viewed!'
            },
            {
                'created_at'  => '14 May 10:34',
                'notes'       => 'Successfully sent receipt to: 87258aba-1333-4dc5-a11a-1befb6251ff7@no-email.com',
                'description' => 'Receipt email sent!',
                'id'          => 'FFCFE17060E246AB9CD867029E53A053'
            },
            {
                'created_at'  => '14 May 10:34',
                'notes'       => 'Invoice viewed!  ',
                'description' => 'Invoice viewed!',
                'id'          => '2A2836B18BEF413994A0F38C9B7B341C'
            },
            {
                'notes'       => 'Invoice viewed!  ',
                'created_at'  => '14 May 09:39',
                'id'          => '3333122EAE584E1085BC6814BD028BEE',
                'description' => 'Invoice viewed!'
            },
            {
                'description' => 'Invoice viewed!',
                'id'          => '6AE4299E01984A4FAE454712F4EFB550',
                'created_at'  => '14 May 09:39',
                'notes'       => 'Invoice viewed!  '
            },
            {
                'notes'       => 'Invoice viewed!  ',
                'created_at'  => '14 May 09:38',
                'id'          => 'A9A10ADE0F70443A9475B0E31F95DC7C',
                'description' => 'Invoice viewed!'
            },
            {
                'notes'       => 'Invoice viewed!  ',
                'created_at'  => '14 May 09:38',
                'id'          => '72355DFD147A4679A7551783F68A29C4',
                'description' => 'Invoice viewed!'
            },
            {
                'id'          => 'A278F69C102047EFADD92FE6FB3B8394',
                'description' => 'Invoice viewed!',
                'created_at'  => '14 May 09:38',
                'notes'       => 'Invoice viewed!  '
            },
            {
                'created_at'  => '14 May 09:38',
                'notes'       => 'Invoice viewed!  ',
                'id'          => 'EC0BA5A4BD5D4E12AC2B3611ADCD57EE',
                'description' => 'Invoice viewed!'
            },
            {
                'id'          => '0A8800BD4C1643F59BF7B13B75E781B5',
                'description' => 'Reminder email sent!',
                'notes'       => 'Successfully sent reminder to: 87258aba-1333-4dc5-a11a-1befb6251ff7@no-email.com',
                'created_at'  => '14 May 09:38'
            }
        ],
        'advance_fee_cents'       => undef,
        'due_date'                => '2018-05-19',
        'installments'            => undef,
        'early_payment_discount'  => \0,
        'early_payment_discounts' => [],
        'total'                   => '35.00 BRL',
        'paid_cents'              => 3500,
        'status'                  => 'paid',
        'items_total_cents'       => 3500,
        'created_at_iso'          => '2018-05-14T09:37:59-03:00',
        'user_id'                 => undef,
        'email'                   => '87258aba-1333-4dc5-a11a-1befb6251ff7@no-email.com',
        'id'                      => '8ED8E2A0FF4E452BB7B2987699AB835D',
        'paid'                    => '35.00 BRL',
        'commission'              => '0.00 BRL',
        'customer_name'           => undef,
        'paid_at'                 => '2018-05-14T10:34:08-03:00',
        'total_overpaid'          => '0.00 BRL',
        'discount'                => undef,
        'commission_cents'        => 0,
        'financial_return_date'   => undef,
        'secure_id'               => '8ed8e2a0-ff4e-452b-b7b2-987699ab835d-afe8',
        'notification_url'        => undef,
        'updated_at'              => '2018-05-14T10:34:08-03:00',
        'currency'                => 'BRL',
        'refundable'              => \0,
        'discount_cents'          => undef,
        'taxes_paid_cents'        => 128,
        'advance_fee'             => undef,
        'tax_cents'               => undef,
        'interest'                => undef,
        'overpaid_cents'          => undef,
        'total_on_occurrence_day' => '35.00 BRL',
        'updated_at_iso'          => '2018-05-14T10:34:08-03:00',
        'variables'               => [
            {
                'variable' => 'payer.address.city',
                'id'       => '8A772AA040FD4725B35A4F55BEEBF3C4',
                'value'    => 'Iguape'
            },
            {
                'value'    => 'Centro',
                'id'       => '41E7886198A34813B040723EBE42B8A5',
                'variable' => 'payer.address.district'
            },
            {
                'value'    => '499',
                'id'       => '1184B77F58B04C56A1400F5663480DE3',
                'variable' => 'payer.address.number'
            },
            {
                'variable' => 'payer.address.state',
                'id'       => 'BD5448BAB60E4267920DA68FBF5638C9',
                'value'    => 'SP'
            },
            {
                'value'    => 'Rua Tiradentes',
                'variable' => 'payer.address.street',
                'id'       => '3B45CC7B1F49497D8A26A5F2C007D474'
            },
            {
                'variable' => 'payer.address.zip_code',
                'id'       => '183648D3DEEB4263A4734A6B27FE5A56',
                'value'    => '11920-000'
            },
            {
                'value'    => '46223869762',
                'id'       => '7C85FF2605C047DC97CE51BD2777BE3A',
                'variable' => 'payer.cpf_cnpj'
            },
            {
                'value'    => 'Kenna Tabitha Taylor',
                'variable' => 'payer.name',
                'id'       => '996CC90426D749B082606F54A86634AF'
            },
            {
                'value'    => '1111',
                'variable' => 'payment_data.transaction_number',
                'id'       => '31ECE59D95414F7AA61449BDA6F4E525'
            },
            {
                'variable' => 'payment_method',
                'id'       => '8CE276AAA5D9480BBDBC7D9F1E41C735',
                'value'    => 'iugu_bank_slip_test'
            }
        ],
        'financial_return_dates' => undef,
        'transaction_number'     => 1111,
        'created_at'             => '14 May 09:37',
        'payment_method'         => 'iugu_bank_slip_test',
        'items'                  => [
            {
                'created_at'  => '2018-05-14T09:37:59-03:00',
                'price_cents' => 3500,
                'quantity'    => 1,
                'description' => "Doação para pre-campanha Joseph CPF 24053924960",
                'id'          => 'E318FDFFB735469BB43C950C79F6DD91',
                'updated_at'  => '2018-05-14T09:37:59-03:00',
                'price'       => '35.00 BRL'
            }
        ],
        'bank_slip'               => undef,
        'taxes_paid'              => '1.28 BRL',
        'cc_emails'               => undef,
        'return_url'              => undef,
        'fines_on_occurrence_day' => '0.00 BRL',
        'ignore_due_email'        => undef,
        'payable_with'            => 'bank_slip'
    };

}

1;
