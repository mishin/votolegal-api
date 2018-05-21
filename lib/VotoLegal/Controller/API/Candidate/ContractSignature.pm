package VotoLegal::Controller::API::Candidate::ContractSignature;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('contract_signature') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model("DB::ContractSignature");
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ( $self, $c ) = @_;

    my $user_id = $c->stash->{candidate}->user->id;

    my $ipAddr = ( $c->req->header("CF-Connecting-IP") || $c->req->header("X-Forwarded-For") || $c->req->address );

    my $contract_signature = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => {
            user_id    => $user_id,
            ip_address => $ipAddr
        }
    );

    return $self->status_created(
        $c,
        location => $c->uri_for_action( $c->action, $c->req->captures, $contract_signature->id )->as_string,
        entity => { id => $contract_signature->id },
    );
}

__PACKAGE__->meta->make_immutable;

1;
