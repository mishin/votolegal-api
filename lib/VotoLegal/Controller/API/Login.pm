package VotoLegal::Controller::API::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

use DDP;

=head1 NAME

VotoLegal::Controller::API::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub login : Chained('/api/root') : PathPart('login') : ActionClass('REST') { }

sub login_POST {
    my ($self, $c) = @_;

    $c->req->params->{email} = lc $c->req->params->{email};

    $c->model('DB::User')->execute($c, for => 'login', with => $c->req->params);

    my $authenticate = $c->authenticate($c->req->params);

    if ($authenticate) {
        my $session = $c->user->new_session(
            ip => $c->req->address,
            %{$c->req->params},
        );

        return $self->status_ok($c, entity => $session);
    }

    return $self->status_bad_request($c, message => 'Bad email or password.');
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
