package VotoLegal::Controller::API::Login::ForgotPassword;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

use DDP;

sub root : Chained('/api/login/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('forgot_password') : CaptureArgs(0) { }

sub forgot_password : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub forgot_password_POST {
    my ($self, $c) = @_;

    my $forgot_password = $c->model('DB::UserForgotPassword')->execute(
        $c,
        for => "create",
        with => $c->req->params,
    );

    return $self->status_ok($c, entity => {
        token => $forgot_password->token,
    });
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
