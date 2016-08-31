package VotoLegal::Controller::API::Register;
use common::sense;
use Moose;
use namespace::autoclean;

use WebService::Slack::IncomingWebHook;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=encoding utf8

=head1 NAME

VotoLegal::Controller::API::Register - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate');
}

sub base : Chained('root') : PathPart('register') : CaptureArgs(0) { }

sub register : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub register_POST {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => {
            %{ $c->req->params },
            status => "pending",
        },
    );

    # Enviando email de confirmação.
    $candidate->send_email_registration();

    # Enviando notificação no Slack.
    if (!is_test) {
        my $name         = $c->req->params->{name};
        my $popular_name = $c->req->params->{popular_name};

        $c->model('DB::SlackQueue')->create({
            channel => "votolegal-bot",
            message => "${name} (${popular_name}) realizou o pré cadastro."
        });
    }

    $self->status_created(
        $c,
        location => $c->uri_for($c->controller('API::Candidate')->action_for('candidate'), [ $candidate->id ]),
        entity   => { id => $candidate->id }
    );
}

=head1 AUTHOR

Junior Moraes L<juniorfvox@gmail.com|mailto:juniorfvox@gmail.com>.

=cut

__PACKAGE__->meta->make_immutable;

1;
