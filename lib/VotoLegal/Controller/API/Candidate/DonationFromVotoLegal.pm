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
            refunded_at => { '!=' => undef },

            candidate_id => $candidate_id
        };
    }
    elsif ( $filter eq 'not_authorized' ) {
        $cond = {
            captured_at  => undef,
            candidate_id => $candidate_id,
            state        => { 'in' => [qw/not_authorized/] },
        };
    }
    elsif ( $filter eq 'pending_payment' ) {
        $cond = {
            candidate_id => $candidate_id,
            captured_at  => undef,

            state => { 'in' => [qw/waiting_boleto_payment boleto_expired/] },
        };
    }
    elsif ( $filter eq 'not_finalized' ) {
        $cond = {
            candidate_id => $candidate_id,
            captured_at  => undef,

            state => { 'in' => [qw/certificate_refused boleto_authentication credit_card_form error_manual_check /] },
        };
    }
    elsif ( $filter eq 'all' ) {
        $cond = { candidate_id => $candidate_id, };
    }
    else {
        die \[ 'filter', 'invalid' ];
    }

    $c->stash->{extra_cols} = [

        { _lr          => \"me.payment_info->'_charge_response_'->>'LR'" },
        { _state       => \"me.state" },
        { _refunded_at => \"me.refunded_at" },
        { _captured_at => \"me.captured_at" },

    ];
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

    my $cond                = $c->stash->{cond}       or die 'must have cond';
    my $order_by_created_at = $c->stash->{order_by}   or die 'must have order_by';
    my $extra_cols          = $c->stash->{extra_cols} or die 'must have extra_cols';

    $c->stash->{max_rows} = $ENV{MAX_DONATIONS_ROWS} || 100;

    my $don_rs = $c->stash->{candidate}->votolegal_donations;

    $c->stash->{donations_rs} = $don_rs->search(
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

                { _marker => \" extract (epoch from captured_at ) || '*' || extract (epoch from created_at )" },

                @$extra_cols,

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
            name  => 'not_authorized',
            label => 'Negadas'
        },
        {
            name  => 'refunded',
            label => 'Estornadas'
        },
        {
            name  => 'pending_payment',
            label => 'Pagamento não efetuado'
        },
        {
            name  => 'not_finalized',
            label => 'Doação não finalizada'
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

    my @keys_to_remove = map { keys %{$_} } @{ $c->stash->{extra_cols} };

    my $don_rs = $c->stash->{candidate}->votolegal_donations;
    foreach my $row (@donations) {
        ( $row->{status}, $row->{motive} ) = $don_rs->_get_status_and_motive($row);

        delete $row->{$_} for @keys_to_remove;
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

    my @keys_to_remove = map { keys %{$_} } @{ $c->stash->{extra_cols} };

    my $don_rs = $c->stash->{candidate}->votolegal_donations;
    foreach my $row (@donations) {
        ( $row->{status}, $row->{motive} ) = $don_rs->_get_status_and_motive($row);

        delete $row->{$_} for @keys_to_remove;
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
