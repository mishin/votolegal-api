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

my $obj = CatalystX::Eta::Test::REST->new(
    do_request => sub {
        my $req = shift;

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
        username              => $username,
        password              => "foobarquux1",
        name                  => fake_name()->(),
        popular_name          => fake_surname()->(),
        email                 => fake_email()->(),
        cpf                   => random_cpf(),
        address_state         => 'SP',
        address_city          => 'Iguape',
        address_zipcode       => '11920-000',
        address_street        => "Rua Tiradentes",
        address_house_number  => 1 + int( rand(2000) ),
        political_movement_id => fake_int( 1, 3 )->(),
        office_id             => 4,
        birth_date            => '11/05/1998',
        party_id              => fake_int( 1, 35 )->(),
        reelection            => fake_int( 0, 1 )->(),
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
        headers => [
            'User-Agent' =>
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/'
              . rand,
        ],
    );

    $obj->{stash}{test_auth} = $res->{device_authorization_token_id};

}

sub generate_rand_donator_data {
    my $info = fake_hash(
        {
            name                         => fake_name(),
            email                        => fake_email(),
            birthdate                    => fake_past_datetime("%Y-%m-%d"),
            address_district             => "Centro",
            address_state                => fake_pick(qw(SP RJ MG RS PR)),
            address_city                 => "Iguape",
            billing_address_house_number => fake_int( 1, 1000 )->(),
            billing_address_district     => "Centro",
            address_street               => "Rua Tiradentes",
            billing_address_city         => "Iguape",
            billing_address_state        => "SP",
            address_zipcode              => "11920-000",
            billing_address_street       => "Rua Tiradentes",
            billing_address_zipcode      => "11920-000",
            address_house_number         => fake_int( 1, 1000 )->(),
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
    }

}
1;
