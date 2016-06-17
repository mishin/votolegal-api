package VotoLegal::Controller::API::Admin::Candidate;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Admin::Candidate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

with 'CatalystX::Eta::Controller::Search';
with 'CatalystX::Eta::Controller::Order';

__PACKAGE__->config(
    # Search
    search_ok => {
        status => 'Str',
    },
    # Order
    order_ok => {
        name => 1,
    },
);

sub root : Chained('/api/admin/root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate')->search({}, { order_by => 'me.name' });
}

sub base : Chained('root') : PathPart('candidate') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $candidate_id) = @_;

    $c->stash->{object}    = $c->stash->{collection}->search({ id => $candidate_id });
    $c->stash->{candidate} = $c->stash->{object}->single;

    if (!$c->stash->{candidate}) {
        $self->status_bad_request($c, message => "Candidate not found");
        $c->detach();
    }
}

sub list : Chained('base') : PathPart('') : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    my $candidate_rs = $c->stash->{collection}->search(
        {},
        {
            #prefetch     => { 'office' },
            #'+select'    => ['office.name'],
            #'+as'        => ['office_name'],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        },
    );

    my @rows ;
    while (my $candidate = $candidate_rs->next()) {
        push @rows, $candidate;
    }

    return $self->status_ok($c, entity => \@rows);
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
