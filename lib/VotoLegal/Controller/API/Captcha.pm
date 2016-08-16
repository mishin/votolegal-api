package VotoLegal::Controller::API::Captcha;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

with "Catalyst::TraitFor::Controller::reCAPTCHA";

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('captcha') : CaptureArgs(0) { }

sub captcha : Chained('base') : PathPart('') : Args(0) {
    my ($self, $c) = @_;

    $c->config->{recaptcha}->{options} = {
        theme => "white",
    };

    $c->forward("captcha_get");

    $c->response->body($c->stash->{recaptcha});
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
