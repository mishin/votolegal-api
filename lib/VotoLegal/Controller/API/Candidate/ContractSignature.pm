package VotoLegal::Controller::API::Candidate::ContractSignature;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils qw/ is_test /;

use DateTime;
use DateTime::Format::Strptime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('contract_signature') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::ContractSignature');

    $c->stash->{parser} = DateTime::Format::Strptime->new(
		pattern  => '%F',
		on_error => 'croak',
    );
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ( $self, $c ) = @_;

    my $user_id = $c->stash->{candidate}->user->id;

    my $ipAddr = ( $c->req->header("CF-Connecting-IP") || $c->req->header("X-Forwarded-For") || $c->req->address );

    my $now;
    if ( is_test() ) {
        $now = $VotoLegal::Test::Further::time_for_contract_test;
    }
    else {
        $now = DateTime->now( time_zone => 'America/Sao_Paulo' );
    }

    my $pre_campaign_end = $c->stash->{parser}->parse_datetime( $ENV{PRE_CAMPAIGN_END_DATE_FOR_LICENSE} );
    my $cmp              = DateTime->compare( $pre_campaign_end, $now );

    my $is_pre_campaign = $cmp == 1 ? 1 : 0;

    my $contract_signature = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => {
            user_id         => $user_id,
            ip_address      => $ipAddr,
            is_pre_campaign => $is_pre_campaign
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
