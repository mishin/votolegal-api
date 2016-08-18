package VotoLegal::Controller::API::Candidate::Donation::Download;
use common::sense;
use Moose;
use namespace::autoclean;

use File::Temp ':seekable';

BEGIN { extends "Catalyst::Controller" }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/donation/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('download') : CaptureArgs(0) { }

sub download : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

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

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
