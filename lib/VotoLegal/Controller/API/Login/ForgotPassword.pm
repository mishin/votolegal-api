package VotoLegal::Controller::API::Login::ForgotPassword;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/login/base') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::UserForgotPassword');
}

sub base : Chained('root') : PathPart('forgot_password') : CaptureArgs(0) { }

sub forgot_password : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub forgot_password_POST {
    my ($self, $c) = @_;

    $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

    return $self->status_ok($c, entity => { message => "ok" });
}

sub reset_password : Chained('base') : PathPart('reset') : Args(1) : ActionClass('REST') { }

sub reset_password_POST {
    my ($self, $c, $token) = @_;

    my $forgot_password = $c->stash->{collection}->search({
        token       => $token,
        valid_until => { '>=', \'NOW()' },
    })->next;

    if ($forgot_password) {
        $forgot_password->execute(
            $c,
            for  => "reset",
            with => $c->req->params,
        );
    }

    return $self->status_ok($c, entity => { message => "ok" });
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
