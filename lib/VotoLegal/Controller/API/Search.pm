package VotoLegal::Controller::API::Search;
use common::sense;
use Moose;
use namespace::autoclean;

use List::Util qw(shuffle);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate')->search({ status => "activated" });
}

sub base : Chained('root') : PathPart('search') : CaptureArgs(0) { }

sub search : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub search_POST {
    my ($self, $c) = @_;

    my $name             = $c->req->params->{name};
    my $party_id         = $c->req->params->{party_id};
    my $office_id        = $c->req->params->{office_id};
    my $address_state    = $c->req->params->{address_state};
    my $address_city     = $c->req->params->{address_city};
    my @issue_priorities = ();

    if ($c->req->params->{issue_priorities}) {
        @issue_priorities = grep { int($_) == $_ } split(m{\s*,\s*}, $c->req->params->{issue_priorities});
    }

    if ($name) {
        $c->stash->{collection} = $c->stash->{collection}->search({
            '-or' => [
                'me.name'         => { 'like' => "%${name}%" },
                'me.popular_name' => { 'like' => "%${name}%" },
            ],
        });
    }

    if ($party_id) {
        $c->stash->{collection} = $c->stash->{collection}->search({
            'me.party_id' => $party_id,
        });
    }

    if ($office_id) {
        $c->stash->{collection} = $c->stash->{collection}->search({
            'me.office_id' => $office_id,
        });
    }

    if (@issue_priorities) {
        $c->stash->{collection} = $c->stash->{collection}->search(
            { '-or' => [ map { 'candidate_issue_priorities.issue_priority_id' => $_ }, @issue_priorities ] },
            { join  => 'candidate_issue_priorities' },
        );
    }

    if ($address_state) {
        $c->stash->{collection} = $c->stash->{collection}->search({ address_state => $address_state });
    }

    if ($address_city) {
        $c->stash->{collection} = $c->stash->{collection}->search({ address_city => $address_city });
    }

    my @random = shuffle $c->stash->{collection}->all;

    my @candidates ;
    for my $candidate (@random) {
        push @candidates, {
            map { $_ => $candidate->$_ }
              qw(id name popular_name username address_state address_city address_street picture)
        };
    }

    return $self->status_ok($c, entity => \@candidates);
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
