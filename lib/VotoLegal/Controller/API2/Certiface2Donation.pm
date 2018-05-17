package VotoLegal::Controller::API2::Certiface2Donation;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with/;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub base : Chained('/api2/base') : PathPart('certiface2donation') : CaptureArgs(0) { }

sub lookup : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

}

sub lookup_GET {
    my ( $self, $c ) = @_;

    my $donation = $c->model('DB::VotolegalDonation')->execute(
        $c,
        for  => "search_by_certiface",
        with => $c->stash->{params}
    );

    $self->status_ok( $c, entity => { donation_id => $donation->id } );
}

__PACKAGE__->meta->make_immutable;

1;
