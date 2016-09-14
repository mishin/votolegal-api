package VotoLegal::Controller::API::Candidate::Donation::Export;
use common::sense;
use Moose;
use namespace::autoclean;

use File::Temp ':seekable';

BEGIN { extends "Catalyst::Controller" }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->forward("/api/forbidden") unless $c->stash->{is_me};

    $c->stash->{collection} = $c->stash->{candidate}->donations;
}

sub base : Chained('root') : PathPart('export') : CaptureArgs(0) { }

sub export : Chained('base') : PathPart('') : Args(0) {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        date => {
            type       => "Str",
            required   => 1,
        },
        receipt_id => {
            type     => "Int",
            required => 1,
        },
    );

    my $date       = $c->req->params->{date};
    my $receipt_id = $c->req->params->{receipt_id};

    $c->stash->{collection} = $c->stash->{collection}->search(\[
        'CAST(captured_at AS DATE) = ?',
        $date,
    ]);

    $c->stash->{collection} = $c->stash->{collection}->search({ status => "captured" });

    my $filehandle = $c->stash->{collection}->export($receipt_id);
    $filehandle->seek(0, SEEK_SET);

    $c->response->content_type("text/plain");
    $c->response->headers->header("content-disposition" => "attachment;filename=doacoes.txt");

    $c->res->body($filehandle);

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
