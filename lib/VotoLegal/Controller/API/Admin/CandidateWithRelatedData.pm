package VotoLegal::Controller::API::Admin::CandidateWithRelatedData;
use Moose;
use namespace::autoclean;

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
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->stash->{collection}->get_candidates_with_data_for_admin();

    my $ret = [];
    my $i = 0;
    while ( my $candidate = $c->stash->{collection}->next() ) {
        my $payment = $candidate->get_most_recent_payment();

        my $payment_status = $candidate->get_account_payment_status();

        $ret->[$i]->{'status da conta'}   = $payment_status;
        $ret->[$i]->{'data de pagamento'} = $payment ? $payment->created_at : 0;
        $ret->[$i]->{'método'}            = $payment ? $payment->get_human_like_method() : 0;
        $ret->[$i]->{'nome'}              = $candidate->name;
        $ret->[$i]->{'cargo'}             = $candidate->office->name;
        $ret->[$i]->{'partido'}           = $candidate->party->name;
        $ret->[$i]->{'movimento'}         = $candidate->political_movement_id ? $candidate->political_movement->name : ();
        $ret->[$i]->{'nome do pagamento'} = $payment ? $payment->name  : 0;
        $ret->[$i]->{'telefone'}          = $payment ? $payment->phone : 0;
        $ret->[$i]->{'estado'}            = $candidate->address_state;
        $ret->[$i]->{'cidade'}            = $candidate->address_city;
        $ret->[$i]->{'cep'}               = $candidate->address_zipcode;
        $ret->[$i]->{'rua'}               = $candidate->address_street;
        $ret->[$i]->{'número'}            = $candidate->address_house_number;
        $ret->[$i]->{'complemento'}       = $candidate->address_complement;

        if (!$payment) {
            $ret->[$i]->{'valor bruto'}   = 0;
            $ret->[$i]->{'taxa'}          = 0;
            $ret->[$i]->{'valor líquido'} = 0;
        }
        else {
            my $payment_pagseguro_data = $payment->get_pagseguro_data();

            if ( $payment_pagseguro_data ) {
                $ret->[$i]->{'valor bruto'}   = $payment_pagseguro_data->{grossAmount};
                $ret->[$i]->{'taxa'}          = $payment_pagseguro_data->{feeAmount};
                $ret->[$i]->{'valor líquido'} = $payment_pagseguro_data->{netAmount};
            }
            else {
                $ret->[$i]->{'valor bruto'}   = 0;
                $ret->[$i]->{'taxa'}          = 0;
                $ret->[$i]->{'valor líquido'} = 0;
            }

        }

        $i += 1;
    }

    return $self->status_ok(
        $c,
        entity => {
            candidates => $ret
        }
    )
}

__PACKAGE__->meta->make_immutable;

1;