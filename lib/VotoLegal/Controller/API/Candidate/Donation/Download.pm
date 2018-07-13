package VotoLegal::Controller::API::Candidate::Donation::Download;
use common::sense;
use Moose;
use namespace::autoclean;

use File::Basename;
use File::Temp ':seekable';

BEGIN { extends "Catalyst::Controller" }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('download') : CaptureArgs(0) { }

sub csv : Chained('base') : PathPart('csv') : Args(0) {
    my ( $self, $c ) = @_;

    my $candidate_id = $c->stash->{candidate}->id;

    $c->stash->{candidate_id} = $candidate_id;
    $c->forward('/api/candidate/donationfromvotolegal/_filter_donation');

    my $cond                = $c->stash->{cond}       or die 'must have cond';
    my $order_by_created_at = $c->stash->{order_by}   or die 'must have order_by';
    my $extra_cols          = $c->stash->{extra_cols} or die 'must have extra_cols';

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    my $don_rs = $c->model("DB::VotoLegalDonation");
    $c->stash->{collection} = $don_rs->search(
        $cond,
        {
            join         => [ 'votolegal_donation_immutable', { 'candidate' => 'party' } ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            order_by => { "-$order_by_created_at" => "created_at" },

            columns => [

                'me.id',
                'me.is_pre_campaign',
                'me.decred_merkle_root',
                'me.decred_capture_txid',
                { donor_name                         => 'votolegal_donation_immutable.donor_name' },
                { donor_cpf                          => 'votolegal_donation_immutable.donor_cpf' },
                { donor_email                        => 'votolegal_donation_immutable.donor_email' },
                { donor_birthdate                    => 'votolegal_donation_immutable.donor_birthdate' },
                { donor_billing_address_state        => 'votolegal_donation_immutable.billing_address_state' },
                { donor_billing_address_city         => 'votolegal_donation_immutable.billing_address_city' },
                { donor_billing_address_zipcode      => 'votolegal_donation_immutable.billing_address_zipcode' },
                { donor_billing_address_district     => 'votolegal_donation_immutable.billing_address_district' },
                { donor_billing_address_street       => 'votolegal_donation_immutable.billing_address_district' },
                { donor_billing_address_house_number => 'votolegal_donation_immutable.billing_address_house_number' },
                { donor_billing_address_complement   => 'votolegal_donation_immutable.billing_address_complement' },
                {
                    amount_human => \"replace((votolegal_donation_immutable.amount/100)::numeric(7, 2)::text, '.', ',')"
                },
                { payment_method_human => \"case when me.is_boleto then 'Boleto' else 'Cartão de crédito' end" },
                {
                    captured_at_human => \
"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.captured_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
                {
                    created_at_human => \
"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.created_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
                {
                    refunded_at_human => \
"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.refunded_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
				{ referral_code        => 'votolegal_donation_immutable.referral_code' },


                @$extra_cols

            ]
        }
    );

    my $csv = Text::CSV->new(
        {
            always_quote => 1,
            eol          => "\n",
            sep_char     => ',',
        }
    );

    my $fh = File::Temp->new( UNLINK => 1, SUFFIX => ".csv" );
    binmode( $fh, ":encoding(UTF-8)" );

    # Header do CSV.
    $csv->print(
        $fh,
        [
            qw(
              ID_DA_DOACAO
              DOACAO_DE_PRE_CAMPANHA
              METODO
              NOME
              CPF
              EMAIL
              TELEFONE
              ESTADO
              CIDADE
              CEP
              BAIRRO
              RUA
              NUMERO
              COMPLEMENTO
              VALOR
              NASCIMENTO
              DATA_DE_CRIAÇÃO
              DATA_DE_CAPTURA
              DATA_DE_ESTORNO
              STATUS
              MOTIVO
              REF
              )
        ]
    );

    while ( my $votolegal_donation = $c->stash->{collection}->next() ) {

        ( $votolegal_donation->{status}, $votolegal_donation->{motive} ) =
          $don_rs->_get_status_and_motive($votolegal_donation);

        $csv->print(
            $fh,
            [
                $votolegal_donation->{id},
                $votolegal_donation->{is_pre_campaign},
                $votolegal_donation->{payment_method_human},
                $votolegal_donation->{donor_name},
                $votolegal_donation->{donor_cpf},
                $votolegal_donation->{donor_email},
                $votolegal_donation->{donor_phone},
                $votolegal_donation->{donor_billing_address_state},
                $votolegal_donation->{donor_billing_address_city},
                $votolegal_donation->{donor_billing_address_zipcode},
                $votolegal_donation->{donor_billing_address_district},
                $votolegal_donation->{donor_billing_address_street},
                $votolegal_donation->{donor_billing_address_house_number},
                $votolegal_donation->{donor_billing_address_complement},
                $votolegal_donation->{amount_human},
                $votolegal_donation->{donor_birthdate},
                $votolegal_donation->{created_at_human},
                $votolegal_donation->{captured_at_human},
                $votolegal_donation->{refunded_at_human},
                $votolegal_donation->{status},
                $votolegal_donation->{motive},
                $votolegal_donation->{referral_code}
            ]
        );
    }

    binmode( $fh, ":raw" );
    $fh->seek( 0, SEEK_SET );

    $c->response->headers->header( "content-disposition" => "attachment;filename=" . basename( $fh->filename ) );
    $c->response->content_type("text/csv");
    $c->res->body($fh);
    $c->detach();
}

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
