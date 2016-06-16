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

sub root : Chained('/api/admin/root') : PathPart('candidate') : CaptureArgs(0) { }

sub pending : Chained('root') : PathPart('pending') : ActionClass('REST') { }

sub pending_GET {
    my ($self, $c) = @_;

    my $candidate_rs = $c->model('DB::Candidate')->search(
        { status => "pendent" },
        {
            #prefetch     => { 'office' },
            #'+select'    => ['office.name'],
            #'+as'        => ['office_name'],
            order_by     => { -asc => 'me.name' },
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        },
    );

    my @rows ;
    while (my $candidate = $candidate_rs->next()) {
        push @rows, $candidate;
    }

    return $self->status_ok($c, entity => {
        candidate => \@rows,   
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
