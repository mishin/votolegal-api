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
    my @donations = $c->stash->{candidate}->votolegal_donations->search(
        {
            # captured_at => { '!=' => undef },
            refunded_at => undef,
        },
        {
            columns => [
                { captured_at      => \"timezone('America/Sao_Paulo', timezone('UTC', me.captured_at))" },
                { refunded_at      => \"timezone('America/Sao_Paulo', timezone('UTC', me.refunded_at))" },
                { is_pre_campaign  => 'me.is_pre_campaign' },
                { is_boleto        => 'me.is_boleto' },
                { amount           => 'votolegal_donation_immutable.amount' },
                { name             => 'votolegal_donation_immutable.donor_name' },
                { email            => 'votolegal_donation_immutable.donor_email' },
                { phone            => 'votolegal_donation_immutable.donor_phone' },
                { birthdate        => 'votolegal_donation_immutable.donor_birthdate' },
                { cpf              => 'votolegal_donation_immutable.donor_cpf' },
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
            donations    => \@donations,
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
