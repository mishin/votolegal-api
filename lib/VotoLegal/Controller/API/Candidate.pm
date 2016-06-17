package VotoLegal::Controller::API::Candidate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Candidate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate');
}

sub base : Chained('root') : PathPart('candidate') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $candidate_id) = @_;

    $c->stash->{candidate} = $c->stash->{collection}->search({ id => $candidate_id })->next;

    if (!$c->stash->{candidate}) {
        $self->status_bad_request($c, message => 'Candidate not found');
        $c->detach();
    }

}

sub candidate : Chained('object') : PathPart('') : ActionClass('REST') { }

sub candidate_GET {
    my ($self, $c) = @_;

    my $candidate = $c->stash->{candidate};

    return $self->status_ok($c, entity => {
        candidate => {
            map { $_ => $candidate->$_ } qw(
              id name popular_name status reelection party_id office_id address_city address_state address_street address_house_number address_complement address_zipcode username)
        },
    });
}

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
