package VotoLegal::Controller::API2;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with is_test/;

BEGIN { extends 'VotoLegal::Controller::API2::Role::REST' }

sub base : Chained('/') : PathPart('api2') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $params = { %{ $c->req->data() && ref $c->req->data eq 'HASH' ? $c->req->data : {} }, %{ $c->req->params } };

    my $ipAddr = $c->req->header("CF-Connecting-IP") || $c->req->address;

    $params->{ip_address} = $ipAddr;

    $c->stash->{params} = $params;

    $c->response->headers->header( charset => "utf-8" );
}

sub recalc_summary : Chained('base') : PathPart('recalc_summary') : Args(0) {
    my ( $self, $c ) = @_;

    $c->res->body('disabled');

    $c->detach() unless ( $c->req->params->{secret} || '' ) eq $ENV{RECALC_SUMMARY_SECRET};

    $_->recalc_summary() for $c->model('DB::Candidate')->search(
        {
            payment_status => 'paid'
        }
    )->all;

    $c->res->body("updated");
}

sub sync_payments : Chained('base') : PathPart('sync_payments') : Args(0) {
    my ( $self, $c ) = @_;

    $c->res->body('disabled');

    $c->detach() unless ( $c->req->params->{secret} || '' ) eq $ENV{RECALC_SUMMARY_SECRET};

    $c->model('DB::VotolegalDonation')->sync_pending_payments(
        loc => sub {
            return is_test() ? join( '', @_ ) : $c->loc(@_);
        },
    );

    $c->res->body("synced");
}

sub julios_sync : Chained('base') : PathPart('julios_sync') : Args(0) {
    my ( $self, $c ) = @_;

    $c->res->body('disabled');

    $c->detach() unless ( $c->req->params->{secret} || '' ) eq $ENV{SYNC_JULIOS_SECRET};

    $c->model('DB::VotolegalDonation')->sync_julios_payments(
        loc => sub {
            return is_test() ? join( '', @_ ) : $c->loc(@_);
        },
    );

    $c->res->body("synced");
}

sub iugu_callback : Chained('base') : PathPart('iugu_callback') : Args(1) {
    my ( $self, $c, $secret ) = @_;

    $c->res->body('disabled');
    $c->detach() if !defined $ENV{IUGU_WEBHOOK_SECRET} || $secret ne $ENV{IUGU_WEBHOOK_SECRET};

    if (   defined $c->req->params->{'data[id]'}
        && $c->req->params->{'event'} eq 'invoice.status_changed'
        && $c->req->params->{'data[account_id]'} eq $ENV{IUGU_WEBHOOK_ACCOUNT_ID} ) {

        my $row = $c->model('DB::VotolegalDonation')->search(
            {
                gateway_tid => $c->req->params->{'data[id]'}
            }
        )->next;

        if ($row) {

            my $update = 0;
            if ( $row->is_boleto ) {

                # queremos ignorar o evento no caso de "criado", só devemos ataulizar o
                # next_gateway_check se o estado souber tratar isso, se nao vai ficar em loop
                # sem ataulizar nunca
                if ( $row->state =~ /(waiting_boleto_payment|wait_for_compensation|done)/ ) {
                    $update = 1;
                }

            }
            else {

                # se for cartao
                if ( $row->state =~ /(wait_for_compensation|done)/ ) {
                    $update = 1;
                }

            }

            if ($update) {

                $row->update( { next_gateway_check => \'now()' } );

            }
        }

    }

    $c->res->body("ok");
}

sub health_check : Chained('base') : PathPart('health_check') : Args(0) {
    my ( $self, $c ) = @_;

    $c->res->body('disabled');

    $c->detach() unless ( $c->req->params->{secret} || '' ) eq $ENV{HEALTH_CHECK_SECRET};

    if (
        $c->model('DB::VotolegalDonation')->search(
            {
                next_gateway_check => \" < now()  - '10 minutes'::interval",
                state              => [qw/wait_for_compensation waiting_boleto_payment boleto_expired/]
            }
        )->count
      ) {
        $c->res->body("too many pending gateway check");
        $c->detach;
    }

    if (
        $ENV{JULIOS_URL}
        && $c->model('DB::VotolegalDonation')->_sync_julios_payments_rs->search(
            {
                julios_next_check => \" < now()  - '10 minutes'::interval",
            }
        )->count
      ) {
        $c->res->body("too many pending julios_next_check");
        $c->detach;
    }

    if (
        $ENV{JULIOS_URL}
        && $c->model('DB::VotolegalDonation')->_sync_julios_payments_rs->search(
            {
                julios_erromsg => { '!=' => undef },
            }
        )->count
      ) {
        $c->res->body("pending julios_erromsg");
        $c->detach;
    }

    if (
        $ENV{JULIOS_URL}
        && $c->model('DB::VotolegalDonation')->search(
            {
                julios_next_check              => \" < now()  - '10 minutes'::interval",
                state                          => [qw/wait_for_compensation refunded done/],
                'candidate.split_rule_id'      => { '!=' => undef },
                'candidate.julios_customer_id' => { '!=' => undef },
            },
            {
                join => 'candidate',
            }
        )->count
      ) {
        $c->res->body("too many pending julios_next_check");
        $c->detach;
    }

    if (
        $c->model('DB::VotolegalDonation')->search(
            {
                state              => [qw/error_manual_check/],
                error_acknowledged => undef
            }
        )->count
      ) {
        $c->res->body("new error not acknowledged");
        $c->detach;
    }

    $c->res->body("good");
}

__PACKAGE__->meta->make_immutable;

1;
