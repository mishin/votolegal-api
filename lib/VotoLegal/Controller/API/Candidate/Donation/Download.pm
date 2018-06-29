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

	my $order_by_created_at = delete $c->req->params->{order_by_created_at} || 'desc';
	die \['order_by_created_at', 'invalid'] unless $order_by_created_at =~ m/(asc|desc)/;

    my $filter = delete $c->req->params->{filter} || 'all';
	die \['filter', 'invalid'] unless $filter =~ m/(captured|refunded|non_completed|refused|all|)/;

    my $cond;
    if ( $filter eq 'captured' ) {
        $cond = {
            captured_at  => \'IS NOT NULL',
            candidate_id => $candidate_id
        };
    }
    elsif ( $filter eq 'refunded' ) {
		$cond = {
            refunded_at  => \'IS NOT NULL',
			candidate_id => $candidate_id
        };
    }
	elsif ( $filter eq 'non_completed' ) {
		$cond = {
            captured_at => \'IS NULL',
            candidate_id => $candidate_id
            -or => [
                state => 'created',
				state => 'boleto_authentication',
				state => 'credit_card_form',
            ]
        };
	}
    elsif ( $filter eq 'refused' ) {
		$cond = {
			candidate_id => $candidate_id,
            -or => [
                state => 'not_authorized',
				state => 'boleto_expired',
				state => 'error_manual_check',
                state => 'certificate_refused'
            ]
        };
    }
    else {
        $cond = {};
    }

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    $c->stash->{collection} = $c->model("DB::VotoLegalDonation")->search(
        $cond,
        {
            join         => [ 'votolegal_donation_immutable', { 'candidate' => 'party' } ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
			order_by     => { "-$order_by_created_at" => "created_at" },

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
                    captured_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.captured_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
                {
                    created_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.created_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
                {
                    refunded_at_human => \"to_char( timezone('America/Sao_Paulo', timezone('UTC', me.refunded_at)) , 'DD/MM/YYYY HH24:MI:SS')"
                },
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
              )
        ]
    );

    while ( my $votolegal_donation = $c->stash->{collection}->next() ) {

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
