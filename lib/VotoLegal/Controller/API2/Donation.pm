package VotoLegal::Controller::API2::Donation;
use Moose;
use namespace::autoclean;
use VotoLegal::Utils qw/die_with/;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub base : Chained('/api2/base') : PathPart('donation') : CaptureArgs(0) { }

sub donation : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

}

sub donation_POST {
    my ( $self, $c ) = @_;

    my $donation = $c->model('DB::VotolegalDonation')->execute(
        $c,
        for  => "create",
        with => $c->stash->{params}
    );

    $self->status_ok( $c, entity => $donation->interface );

}

__PACKAGE__->meta->make_immutable;

1;
