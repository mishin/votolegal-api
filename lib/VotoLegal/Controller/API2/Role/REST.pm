package VotoLegal::Controller::API2::Role::REST;
use utf8;

use VotoLegal::Utils;

use Moose;
use namespace::autoclean;
use Data::Dumper qw(Dumper);
use JSON::MaybeXS;
use Encode qw/decode_utf8/;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    'map'   => {
        'application/json' => 'JSON',
        'text/x-json'      => 'JSON',
    },
);

sub end : Private {
    my ( $self, $c ) = @_;
    my $code = $c->res->status;

    # upgrade de erros
    if (   exists $c->stash->{rest}
        && ref $c->stash->{rest} eq 'HASH'
        && exists $c->stash->{rest}{error}
        && $c->stash->{rest}{error} eq 'form_error' ) {
        my ($any_error) = keys %{ $c->stash->{rest}{form_error} };
        if ( my $error_msg = $c->stash->{rest}{form_error}{$any_error} ) {

            $c->stash->{rest} = [ $c->build_api_error( msg_id => "$any_error-$error_msg" ) ];
        }
        else {
            $c->stash->{rest} = [ $c->build_api_error( msg_id => 'internal-error' ) ];
        }
    }

    my $err;
    if ( scalar @{ $c->error } ) {
        $code = 500;
        $c->stash->{errors} = $c->error;
        my ( $top, @others ) = @{ $c->error };

        if ( ref $top eq 'HASH' and scalar @{$top}{qw(msg_id)} ) {
            $c->stash->{rest} = [ $c->build_api_error(%$top) ];
            $code = 400;
        }
        elsif ( ref $top eq 'REF' && ref $$top eq 'ARRAY' && @$$top == 2 ) {
            $c->stash->{rest} = [ $c->build_api_error( msg_id => $$top->[0] . '_' . $$top->[1] ) ];
            $code = 400;
        }
        elsif ( ref $top eq 'DBIx::Class::Exception' ) {

            if ( $top =~ /violates not-null constraint/ ) {
                my ($col) = $top =~ /column "([^"]+)" violates/;
                $c->stash->{rest} = [ $c->build_api_error( msg_id => "${col}-invalid" ) ];
                $code = 400;
            }
            elsif ( $top =~ /violates check constraint/ ) {
                my ($cons) = $top =~ /violates check constraint "([^"]+)"/;
                $cons =~ s/[0-9]+$//;
                $c->stash->{rest} = [ $c->build_api_error( msg_id => "${cons}" ) ];
                $code = 400;
            }

        }

        $c->log->error( $c->req->uri->as_string
              . ( $c->req->data   ? Dumper( $c->req->data )   : '' ) . " - "
              . ( $c->req->params ? Dumper( $c->req->params ) : '' ) );

        $err = '';
        foreach my $error ( $top, @others ) {
            $err .= Dumper $error;
        }
        ( $err = substr $err, 0, 5000 . "\n" ),
          $err =~ s|^(\s+)| my $x = length($1); $x /= 6; $x = $x ? $x : 0; $x = ' ' x $x; $x |emg
          if $err =~ /InvalidBaseTypeGivenToCreateParameterizedTypeConstraint/;
        $c->log->error($err)
          unless $code == 400 && ( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ );
        $c->clear_errors;

    }

    if ( $code =~ /^5/ && !$c->res->body && !$c->stash->{rest} ) {
        $code = 500;
        eval {
            $err = substr( $err, 0, 350 ) . ':koko:' . substr( $err, -250 )
              if length $err > 603;
            remote_notify( "Erro 500 $err", channel => '#api-error' );
        };
        $c->stash->{rest} = [
            {
                msg_id  => 'internal-error-interno',
                message => 'Erro interno, tente novamente mais tarde',
            }
        ];

    }
    elsif ( ref $c->stash->{rest} eq 'ARRAY' && $c->stash->{rest}[0]{msg_id} =~ /internal/ ) {

        if ( !( $ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/ ) ) {
            eval {
                my $err = decode_utf8(
                    encode_json(
                        {
                            body    => $c->stash->{rest},
                            user_id => ( $c->user ? $c->user->id : '-' ),
                            api_key => ( $c->stash->{_session} ? $c->stash->{_session}->api_key : '-' )
                        }
                    )
                );
                remote_notify( "Critical 400 $err", channel => '#api-error' );
            };
        }

    }

    $c->res->status($code);
    $c->forward('serialize');

}

sub serialize : ActionClass('Serialize') {
}
