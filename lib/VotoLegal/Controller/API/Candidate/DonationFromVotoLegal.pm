package VotoLegal::Controller::API::Candidate::DonationFromVotoLegal;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('votolegal-donations') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    # O candidato vê apenas doações do VotoLegal.
    my @captured_donations = $c->stash->{candidate}->votolegal_donations->search(
        {
            captured_at => { '!=' => undef },
            refunded_at => undef,
        },
        {
            columns => [
                {
					captured_at => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.captured_at)) , 'DD/MM/YYYY HH24:MI:SS')"
				},
				{
					created_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.created_at)) , 'DD/MM/YYYY HH24:MI:SS')"
				},
                { is_pre_campaign      => 'me.is_pre_campaign' },
                { payment_method_human => \"case when me.is_boleto then 'Boleto' else 'Cartão de crédito' end" },
                {
					amount => \"replace((votolegal_donation_immutable.amount/100)::numeric(7, 2)::text, '.', ',')"
				},
                { name             => 'votolegal_donation_immutable.donor_name' },
                { email            => 'votolegal_donation_immutable.donor_email' },
                { phone            => 'votolegal_donation_immutable.donor_phone' },
                { birthdate        => 'votolegal_donation_immutable.donor_birthdate' },
                { cpf              => 'votolegal_donation_immutable.donor_cpf' },
                { address_state    => 'votolegal_donation_immutable.billing_address_state' },
                { address_city     => 'votolegal_donation_immutable.billing_address_city' },
                { address          => \"concat( votolegal_donation_immutable.billing_address_street, ', ', votolegal_donation_immutable.billing_address_house_number, ' ', votolegal_donation_immutable.billing_address_complement )" },
				{ address_zipcode  => 'votolegal_donation_immutable.billing_address_zipcode' },
				{ address_district => 'votolegal_donation_immutable.billing_address_district' },
                { transaction_hash => 'me.decred_capture_txid' },
                { id               => 'me.id' },
                { payment_succeded => \"me.payment_info->'_charge_response_'->>'success'" },
                { payment_lr       => \"me.payment_info->'_charge_response_'->>'LR'" },
                { payment_message  => \"me.payment_info->'_charge_response_'->>'message'" },
            ],
            join         => 'votolegal_donation_immutable',
            order_by     => [ { '-desc' => "captured_at" }, { '-desc', 'me.created_at' } ],
            page         => 1,
            rows         => 100,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all();

    my @refunded_donations = $c->stash->{candidate}->votolegal_donations->search(
        { refunded_at => { '!=' => undef } },
        {
			columns => [
				{
					captured_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.captured_at)) , 'DD/MM/YYYY HH24:MI:SS')"
				},
				{
					created_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.created_at)) , 'DD/MM/YYYY HH24:MI:SS')"
				},
                {
					refunded_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.refunded_at)) , 'DD/MM/YYYY HH24:MI:SS')"
				},
				{ is_pre_campaign      => 'me.is_pre_campaign' },
				{ payment_method_human => \"case when me.is_boleto then 'Boleto' else 'Cartão de crédito' end" },
				{
					amount_human => \"replace((votolegal_donation_immutable.amount/100)::numeric(7, 2)::text, '.', ',')"
				},
				{ name             => 'votolegal_donation_immutable.donor_name' },
				{ email            => 'votolegal_donation_immutable.donor_email' },
				{ phone            => 'votolegal_donation_immutable.donor_phone' },
				{ birthdate        => 'votolegal_donation_immutable.donor_birthdate' },
				{ cpf              => 'votolegal_donation_immutable.donor_cpf' },
				{ address_state    => 'votolegal_donation_immutable.billing_address_state' },
				{ address_city     => 'votolegal_donation_immutable.billing_address_city' },
				{ address          => \"concat( votolegal_donation_immutable.billing_address_street, ', ', votolegal_donation_immutable.billing_address_house_number, ' ', votolegal_donation_immutable.billing_address_complement )" },
				{ address_zipcode  => 'votolegal_donation_immutable.billing_address_zipcode' },
				{ address_district => 'votolegal_donation_immutable.billing_address_district' },
				{ transaction_hash => 'me.decred_capture_txid' },
				{ id               => 'me.id' },
				{ payment_succeded => \"me.payment_info->'_charge_response_'->>'success'" },
				{ payment_lr       => \"me.payment_info->'_charge_response_'->>'LR'" },
				{ payment_message  => \"me.payment_info->'_charge_response_'->>'message'" },
			  ],
            join         => 'votolegal_donation_immutable',
            order_by     => [ { '-desc' => "captured_at" }, { '-desc', 'me.created_at' } ],
            page         => 1,
            rows         => 100,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all();

    my @non_completed_donations = $c->stash->{candidate}->votolegal_donations->search(
        {
            captured_at => \'IS NULL',
            refunded_at => \'IS NULL',
            state      => { '!=' => 'created' }
        },
        {
			columns => [
				{
					captured_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.captured_at)) , 'DD/MM/YYYY HH24:MI:SS')"
				},
				{
					created_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.created_at)) , 'DD/MM/YYYY HH24:MI:SS')"
				},
				{ is_pre_campaign      => 'me.is_pre_campaign' },
				{ payment_method_human => \"case when me.is_boleto then 'Boleto' else 'Cartão de crédito' end" },
				{
					amount_human => \"replace((votolegal_donation_immutable.amount/100)::numeric(7, 2)::text, '.', ',')"
				},
                { status           => \"case me.state
                                            when 'boleto_authentication'  then 'Aguardando prova de vida'
                                            when 'certificate_refused'    then 'Teste de biometria falhou'
                                            when 'waiting_boleto_payment' then 'Aguardando pagamento do boleto'
                                            when 'not_authorized'         then 'Não autorizado'
                                            when 'error_manual_check'     then 'Erro, entrar em contato'
                                            when 'wait_for_compensation'  then 'Aguardando compensação financeira'
                                        end" },
				{ name             => 'votolegal_donation_immutable.donor_name' },
				{ email            => 'votolegal_donation_immutable.donor_email' },
				{ phone            => 'votolegal_donation_immutable.donor_phone' },
				{ birthdate        => 'votolegal_donation_immutable.donor_birthdate' },
				{ cpf              => 'votolegal_donation_immutable.donor_cpf' },
				{ address_state    => 'votolegal_donation_immutable.billing_address_state' },
				{ address_city     => 'votolegal_donation_immutable.billing_address_city' },
				{ address          => \"concat( votolegal_donation_immutable.billing_address_street, ', ', votolegal_donation_immutable.billing_address_house_number, ' ', votolegal_donation_immutable.billing_address_complement )" },
				{ address_zipcode  => 'votolegal_donation_immutable.billing_address_zipcode' },
				{ address_district => 'votolegal_donation_immutable.billing_address_district' },
				{ transaction_hash => 'me.decred_capture_txid' },
				{ id               => 'me.id' },
				{ payment_succeded => \"me.payment_info->'_charge_response_'->>'success'" },
				{ payment_lr       => \"me.payment_info->'_charge_response_'->>'LR'" },
				{ payment_message  => \"me.payment_info->'_charge_response_'->>'message'" },
			  ],
            join         => 'votolegal_donation_immutable',
            order_by     => [ { '-desc' => "captured_at" }, { '-desc', 'me.created_at' } ],
            page         => 1,
            rows         => 100,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all();

    return $self->status_ok(
        $c,
        entity => {
            donations               => \@captured_donations,
            refunded_donations      => \@refunded_donations,
            non_completed_donations => \@non_completed_donations,
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
