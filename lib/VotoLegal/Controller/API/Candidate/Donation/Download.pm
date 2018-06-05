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

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    $c->stash->{collection} = $c->model("DB::VotoLegalDonation")->search(
        {
            candidate_id => $c->stash->{candidate}->id,
            captured_at  => \'IS NOT NULL'
        },
        {
            join         => [ 'votolegal_donation_immutable', { 'candidate' => 'party' } ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',

			columns => [

				'me.id',
				'me.is_pre_campaign',
				'me.decred_merkle_root',
				'me.decred_capture_txid',
				'candidate.campaign_donation_type',
				'candidate.cpf',
				'candidate.name',
				'candidate.cnpj',
				{ party_name  => 'party.name' },
				{ donor_name  => 'votolegal_donation_immutable.donor_name' },
				{ donor_cpf   => 'votolegal_donation_immutable.donor_cpf' },
				{ donor_email => 'votolegal_donation_immutable.donor_email' },
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

    my $votolegal_donation_rs = $c->stash->{collection}->search( { candidate_id => $c->stash->{candidate}->id } );

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
              NAME
              CPF
              EMAIL
              PHONE
              STATE
              CITY
              ADDRESS
              AMOUNT
              BIRTHDATE
              DATE
              )
        ]
    );

    while ( my $votolegal_donation = $votolegal_donation_rs->next() ) {
        use DDP; p $votolegal_donation;
        my $address_street       = $votolegal_donation->address_street       || "";
        my $address_complement   = $votolegal_donation->address_complement   || "";
        my $address_house_number = $votolegal_donation->address_house_number || "";

        $csv->print(
            $fh,
            [
                $votolegal_donation->name,
                $votolegal_donation->cpf,
                $votolegal_donation->email,
                $votolegal_donation->phone,
                $votolegal_donation->address_state,
                $votolegal_donation->address_city,
                sprintf( "%s %s, %s", $address_street, $address_complement, $address_house_number ),
                sprintf( "%.2f",      $result->amount / 100 ),
                $votolegal_donation->birthdate->strftime("%d/%m/%Y"),
                $votolegal_donation->captured_at->strftime("%d/%m/%Y %H:%M:%S"),
            ]
        );
    }

    # binmode( $fh, ":raw" );
    # $fh->seek( 0, SEEK_SET );

    # $c->response->headers->header( "content-disposition" => "attachment;filename=" . basename( $fh->filename ) );
    # $c->response->content_type("text/csv");
    # $c->res->body($fh);
    # $c->detach();
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
