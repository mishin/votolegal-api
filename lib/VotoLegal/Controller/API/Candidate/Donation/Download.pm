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

    my $donation_rs = $c->stash->{collection}->search(
        {
            candidate_id => $c->stash->{candidate}->id,
            status       => "captured",
            by_votolegal => "t",
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

    while ( my $result = $donation_rs->next() ) {
        my $address_street       = $result->address_street       || "";
        my $address_complement   = $result->address_complement   || "";
        my $address_house_number = $result->address_house_number || "";

        $csv->print(
            $fh,
            [
                $result->name,
                $result->cpf,
                $result->email,
                $result->phone,
                $result->address_state,
                $result->address_city,
                sprintf( "%s %s, %s", $address_street, $address_complement, $address_house_number ),
                sprintf( "%.2f",      $result->amount / 100 ),
                $result->birthdate->strftime("%d/%m/%Y"),
                $result->captured_at->strftime("%d/%m/%Y %H:%M:%S"),
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
