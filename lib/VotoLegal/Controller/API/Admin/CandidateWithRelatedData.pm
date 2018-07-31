package VotoLegal::Controller::API::Admin::CandidateWithRelatedData;
use Moose;
use namespace::autoclean;

use DateTime::Format::Pg;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(

    # AutoBase.
    result => "DB::Candidate",
);

sub root : Chained('/api/admin/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('candidate-with-related-data') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->stash->{collection}->get_candidates_with_data_for_admin();

    my $ret = [];
    my $i   = 0;
    while ( my $candidate = $c->stash->{collection}->next() ) {
        my $payment = $candidate->get_most_recent_payment();

        my $payment_status = $candidate->get_account_payment_status();

        my $payment_created_at = $payment ? DateTime::Format::Pg->parse_datetime( $payment->created_at )->dmy('/') : 0;

        $ret->[$i]->{'status da conta'}   = $payment_status;
        $ret->[$i]->{'pagina publicada'}  = $candidate->is_published ? 'ATIVO' : 'DESABILITADO';
        $ret->[$i]->{'url'}               = "www.votolegal.com.br/em/" . $candidate->username;
        $ret->[$i]->{'data de pagamento'} = $payment_created_at;
        $ret->[$i]->{'cod. do pagamento'} = $payment ? $payment->code : 0;
        $ret->[$i]->{'metodo'}            = $payment ? $payment->get_human_like_method() : 0;
        $ret->[$i]->{'nome do candidato'} = $candidate->name;
        $ret->[$i]->{'cpf'}               = $candidate->cpf;
        $ret->[$i]->{'email'}             = $candidate->user->email;
        $ret->[$i]->{'cargo'}             = $candidate->office->name;
        $ret->[$i]->{'partido'}           = $candidate->party->name;
        $ret->[$i]->{'movimento'}         = $candidate->political_movement_id ? $candidate->political_movement->name : 0;
        $ret->[$i]->{'nome do pagamento'} = $payment ? $payment->name : 0;
        $ret->[$i]->{'telefone'}          = $payment ? $payment->phone : 0;
        $ret->[$i]->{'estado'}            = $candidate->address_state;
        $ret->[$i]->{'cidade'}            = $candidate->address_city;
        $ret->[$i]->{'cep'}               = $candidate->address_zipcode;
        $ret->[$i]->{'rua'}               = $candidate->address_street;
        $ret->[$i]->{'numero'}            = $candidate->address_house_number;
        $ret->[$i]->{'complemento'}       = $candidate->address_complement;

        if ( !$payment ) {
            $ret->[$i]->{'valor bruto'}   = 0;
            $ret->[$i]->{'taxa'}          = 0;
            $ret->[$i]->{'valor liquido'} = 0;
        }
        else {

            if ( $payment->has_amount_data ) {
                $ret->[$i]->{'valor bruto'}   = $payment->gross_amount;
                $ret->[$i]->{'taxa'}          = $payment->fee_amount;
                $ret->[$i]->{'valor liquido'} = $payment->net_amount;

                $ret->[$i]->{'valor bruto'}   =~ s/\./,/g;
                $ret->[$i]->{'taxa'}          =~ s/\./,/g;
                $ret->[$i]->{'valor liquido'} =~ s/\./,/g;
            }
            else {
                my $payment_data = $payment->get_iugu_data();

                if ($payment_data) {
                    # $payment_data->{total_cents} =~ s/\./,/g;
                    # $payment_data->{taxes_paid_cents}   =~ s/\./,/g;
                    # $payment_data->{netAmount}   =~ s/\./,/g;

                    $ret->[$i]->{'valor bruto'}   = $payment_data->{total_cents};
                    $ret->[$i]->{'taxa'}          = $payment_data->{taxes_paid_cents};
                    $ret->[$i]->{'secure_id'}     = $payment_data->{secure_id};
                }
                else {
                    $ret->[$i]->{'valor bruto'}   = 0;
                    $ret->[$i]->{'taxa'}          = 0;
                    $ret->[$i]->{'valor liquido'} = 0;
                }
            }

        }

        if ( !defined $ret->[$i]->{'valor bruto'} ) {
            $ret->[$i]->{'valor bruto'} = 0;
        }
        if ( !defined $ret->[$i]->{'taxa'} ) {
            $ret->[$i]->{'taxa'} = 0;
        }
        if ( !defined $ret->[$i]->{'valor liquido'} ) {
            $ret->[$i]->{'valor liquido'} = 0;
        }

        $i += 1;
    }

    return $self->status_ok(
        $c,
        entity => {
            candidates => $ret
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
