package VotoLegal::Controller::API::Certiface2DonationRedirect;
use Moose;
use utf8;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }
use UUID::Tiny qw/is_uuid_string/;

use URI;

sub base : Chained('/api/root') : PathPart('certiface2donation-redirect') : CaptureArgs(0) { }

sub lookup : Chained('base') : PathPart('') : Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->req->params->{token} && is_uuid_string( $c->req->params->{token} ) ) {

        my $token = $c->model('DB::CertifaceToken')->search(
            {
                'me.id' => $c->req->params->{token}
            },
            {
                prefetch => 'certiface_return_url'
            }
        )->next;

        if ($token) {

            $token->update( { certiface_return_count => \'certiface_return_count + 1' } );

            my $url = $token->certiface_return_url->url;

            my $uri = URI->new($url);

            $uri->query_form( 'donation_id' => $token->votolegal_donation_id );

            $c->response->redirect( $uri->as_string, 302 );

            $c->detach;
        }

    }

    $c->res->body('Token não encontrado!');
}

__PACKAGE__->meta->make_immutable;

1;
