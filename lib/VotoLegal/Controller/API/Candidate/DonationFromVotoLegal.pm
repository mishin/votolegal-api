package VotoLegal::Controller::API::Candidate::DonationFromVotoLegal;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

use DateTime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub _filter_donation : Private {
    my ( $self, $c ) = @_;

    my $candidate_id = $c->stash->{candidate_id} or die 'must have candidate_id';

    my $sort_dir = delete $c->req->params->{order_by_created_at} || 'desc';
    die \[ 'order_by_created_at', 'invalid' ] unless $sort_dir =~ m/(asc|desc)/;

    my $filter = delete $c->req->params->{filter} || 'all';
    die \[ 'filter', 'invalid' ] unless $filter =~ m/(captured|refunded|non_completed|refused|all|)/;

    my $cond;
    if ( $filter eq 'captured' ) {
        $cond = {
            captured_at => { '!=' => undef },
            refunded_at => undef,

            candidate_id => $candidate_id
        };
    }
    elsif ( $filter eq 'refunded' ) {
        $cond = {
            refunded_at  => { '!=' => undef },
            candidate_id => $candidate_id
        };
    }
    elsif ( $filter eq 'non_completed' ) {
        $cond = {
            captured_at  => undef,
            candidate_id => $candidate_id,
            state        => { 'in' => [qw/created boleto_authentication credit_card_form certificate_refused/] },
        };
    }
    elsif ( $filter eq 'refused' ) {
        $cond = {
            candidate_id => $candidate_id,

            state => { 'in' => [qw/not_authorized boleto_expired/] },
        };
    }
    else {
        $cond = {};
    }

    $c->stash->{cond}     = $cond;
    $c->stash->{order_by} = $sort_dir;

}

sub base : Chained('root') : PathPart('votolegal-donations') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Tratando o filtro default aqui vai ser o captured
    $c->req->params->{filter} ||= 'captured';

    my $candidate_id = $c->stash->{candidate}->id;
    $c->stash->{candidate_id} = $candidate_id;
    $c->forward('/api/candidate/donationfromvotolegal/_filter_donation');

    my $cond                = $c->stash->{cond}     or die 'must have cond';
    my $order_by_created_at = $c->stash->{order_by} or die 'must have order_by';

    $c->stash->{max_rows} = $ENV{MAX_DONATIONS_ROWS} || 100;

    $c->stash->{donations_rs} = $c->stash->{candidate}->votolegal_donations->search(
        $cond,
        {
            columns => [
                {
                    captured_at => \
"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.captured_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
                {
                    created_at_human => \
"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.created_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
                {
                    refunded_at => \
"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.refunded_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
                { is_pre_campaign      => 'me.is_pre_campaign' },
                { payment_method_human => \"case when me.is_boleto then 'Boleto' else 'Cartão de crédito' end" },
                {
                    amount => \"replace((votolegal_donation_immutable.amount/100)::numeric(7, 2)::text, '.', ',')"
                },
                {
                    status => \
"case when me.captured_at is not null then 'captured' when me.refunded_at is not null then 'refunded' else 'non_completed' end"
                },
                { name                 => 'votolegal_donation_immutable.donor_name' },
                { email                => 'votolegal_donation_immutable.donor_email' },
                { phone                => 'votolegal_donation_immutable.donor_phone' },
                { birthdate            => 'votolegal_donation_immutable.donor_birthdate' },
                { cpf                  => 'votolegal_donation_immutable.donor_cpf' },
                { address_state        => 'votolegal_donation_immutable.billing_address_state' },
                { address_city         => 'votolegal_donation_immutable.billing_address_city' },
                { address_house_number => 'votolegal_donation_immutable.address_house_number' },
                { address_street       => 'votolegal_donation_immutable.billing_address_street' },
                { address_complement   => 'votolegal_donation_immutable.address_complement' },
                { address_zipcode      => 'votolegal_donation_immutable.billing_address_zipcode' },
                { address_district     => 'votolegal_donation_immutable.billing_address_district' },
                { transaction_hash     => 'me.decred_capture_txid' },
                { transaction_link     => \"concat('https://mainnet.decred.org/tx/', me.decred_capture_txid)" },
                { id                   => 'me.id' },
                { payment_succeded     => \"me.payment_info->'_charge_response_'->>'success'" },
                { payment_lr           => \"me.payment_info->'_charge_response_'->>'LR'" },
                {
                    payment_message => \
"case when me.payment_info->'_charge_response_'->>'message' = 'Transaction declined' then 'Transação negada' else me.payment_info->'_charge_response_'->>'message' end"
                },
                { _marker => \" extract (epoch from captured_at ) || '*' || extract (epoch from created_at )" },
            ],
            join     => 'votolegal_donation_immutable',
            order_by => [ { "-$order_by_created_at" => "captured_at" }, { "-$order_by_created_at" => "created_at" } ],
            rows     => $c->stash->{max_rows} + 1,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    );

    $c->stash->{statuses} = [
        {
            name  => 'captured',
            label => 'Autorizadas'
        },
        {
            name  => 'refunded',
            label => 'Estornadas'
        },
        {
            name  => 'non_completed',
            label => 'Não concluídas'
        },
        {
            name  => 'refused',
            label => 'Doações não autorizadas ou não compensadas'
        }
    ];
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    my @donations = $c->stash->{donations_rs}->all();

    my $has_more = 0;
    if ( @donations == $c->stash->{max_rows} + 1 ) {
        $has_more++;
        pop @donations;
    }

    return $self->status_ok(
        $c,
        entity => {
            donations    => \@donations,
            statuses     => $c->stash->{statuses},
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime(),
            has_more     => $has_more ? 1 : 0,
        }
    );
}

sub list_more : Chained('base') : PathPart('') : Args(1) : ActionClass('REST') { }

sub list_more_GET {
    my ( $self, $c, $timestamps ) = @_;

    if ( $timestamps !~ /^[0-9]{10,11}(\.[0-9]{1,5})?\*[0-9]{10,11}(\.[0-9]{1,5})?$/ ) {
        $self->status_not_found( $c, message => 'invalid pagination' );
        $c->detach();
    }

    my ( $captured_at, $created_at ) = split /\*/, $timestamps;

    my $op = is_test() ? '<' : '<=';
    my @donations = $c->stash->{donations_rs}->search(
        {
            # capture precisao de segundos, entao pode trazer os que sao iguais
            # durante o teste, preciso ignorar isso
            captured_at => { $op => \[ "to_timestamp(?)", $captured_at ] },
            created_at  => { '<' => \[ "to_timestamp(?)", $created_at ] },
        }
    )->all();

    my $has_more = 0;
    if ( @donations == $c->stash->{max_rows} + 1 ) {
        $has_more++;
        pop @donations;
    }

    return $self->status_ok(
        $c,
        entity => {
            donations => \@donations,
            has_more  => $has_more ? 1 : 0,
            statuses  => $c->stash->{statuses},
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
