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

# Rota desativada por enquanto.
#sub download : Chained('base') : PathPart('') : Args(0) { }

sub download_GET {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        date => {
            type       => "Str",
            required   => 1,
            post_check => sub {
                1;
            },
        },
    );

    my $date       = $c->req->params->{date};
    my $filehandle = $c->stash->{candidate}->export_donations_to_tse($date);
    $filehandle->seek(0, SEEK_SET);

    $c->response->content_type("text/plain");
    $c->response->headers->header("content-disposition" => "attachment;filename=doacoes.txt");

    $c->res->body($filehandle);

    $c->detach();
}

sub csv : Chained('base') : PathPart('csv') : Args(0) {
    my ($self, $c) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    my $donation_rs = $c->stash->{collection}->search({
        candidate_id => $c->stash->{candidate}->id,
        status       => "captured",
    });

    my $csv = Text::CSV->new({
        always_quote => 1,
        eol          => "\n",
        sep_char     => ',',
    });

    my $fh = File::Temp->new(UNLINK => 1);

    # Header do CSV.
    $csv->print($fh, [ qw(
        name
        cpf
        email
        birthdate
        date
    )]);

    while (my $result = $donation_rs->next()) {
        $csv->print($fh, [
            $result->name,
            $result->cpf,
            $result->email,
            $result->birthdate->strftime("%d/%m/%Y"),
            $result->captured_at->strftime("%d/%m/%Y %H:%M:%S"),
        ]);
    }

    $fh->seek(0, SEEK_SET);

    $c->response->headers->header("content-disposition" => "attachment;filename=" . basename($fh->filename));
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
