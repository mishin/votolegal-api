package VotoLegal::Controller::API::Login;
use Moose;
use namespace::autoclean;

use VotoLegal::Types qw(EmailAddress);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('login') : CaptureArgs(0) { }

sub login : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub login_POST {
    my ($self, $c) = @_;

    $c->req->params->{email} = lc $c->req->params->{email};

    $self->validate_request_params(
        $c,
        email => {
            type     => EmailAddress,
            required => 1,
        },
        password => {
            type     => "Str",
            required => 1,
        },
    );

    if ($c->authenticate($c->req->params)) {
        my $session = $c->user->new_session(
            ip => $c->req->address,
            %{$c->req->params},
        );

        # Barrando o login de candidatos que foram desaprovados.
        if (my $candidate = $c->user->candidates->next) {
            if ($candidate->status ne "deactivated") {
                return $self->status_ok($c, entity => $session);
            }
        }
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
