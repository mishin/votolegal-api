package VotoLegal::Controller::API::Certiface::Token::Validate;
use common::sense;
use Moose;
use namespace::autoclean;

use WebService::Certiface;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

has _certiface => (
    is         => "ro",
    isa        => "WebService::Certiface",
    lazy_build => 1,
);

sub _build__certiface { WebService::Certiface->instance }

sub root : Chained('/api/certiface/token/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('validate') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model("DB::CertifaceToken");
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

# A API do Certiface está utilizando GET
sub list_GET {
    my ($self, $c) = @_;
    use DDP; p $c->req;

    my $token_uuid = $c->req->data->{token};
    die \['token', 'missing'] unless $token_uuid;

    my $token = $c->stash->{collection}->search( { uuid => $token_uuid } )->next;
    die \['token', 'could not find token with that uuid'] unless $token;

    my $token_information = $self->_certiface->get_token_information($token_uuid);

    if ($token_information->{status} == 1) {
        $token->update_token_status()
    }
    else {
        die \['token', 'certiface token validation did not succeeded']
    }

    return $self->status_ok(
        $c,
        entity => {
            token_uuid => $token_uuid
        }
    );
}

sub list_POST {
    my ($self, $c) = @_;
    use DDP; p $c->req;

    my $token_uuid = $c->req->data->{token} || $c->req->params->{token};
    die \['token', 'missing'] unless $token_uuid;

    my $token = $c->stash->{collection}->search( { uuid => $token_uuid } )->next;
    die \['token', 'could not find token with that uuid'] unless $token;

    my $token_information = $self->_certiface->get_token_information($token_uuid);

    if ($token_information->{status} == 1) {
        $token->update_token_status()
    }
    else {
        die \['token', 'certiface token validation did not succeeded']
    }

    return $self->status_ok(
        $c,
        entity => {
            token_uuid => $token_uuid,
            boleto_url => 'https://gallery.mailchimp.com/d3a90e0e7418b8c4e14997e44/files/ea2cb234-7c37-4999-ba37-faeecfbb359c/Boleto__8_.pdf'
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
