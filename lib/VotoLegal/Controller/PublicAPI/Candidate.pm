package VotoLegal::Controller::PublicAPI::Candidate;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/publicapi/root') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate')->search( { status => 'activated' } );
}

sub base : Chained('root') : PathPart('candidate') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $args ) = @_;

    # Quando o parâmetro é inteiramente numérico, o buscamos como id.
    # Quando não é, pesquisamos pelo 'slug'.
    my $candidate;
    if ( $args =~ m{^[0-9]+$} ) {
        $candidate = $c->stash->{collection}->search( { 'me.id' => $args } )->next;
    }
    else {
        $candidate = $c->stash->{collection}->search( { 'me.username' => $args } )->next;
    }

    if ( !$candidate ) {
        $self->status_not_found( $c, message => 'Candidate not found' );
        $c->detach();
    }

    $c->stash->{candidate} = $candidate;
}

__PACKAGE__->meta->make_immutable;

1;
