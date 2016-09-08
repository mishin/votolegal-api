package VotoLegal::Controller::API::Stats;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('stats') : CaptureArgs(0) { }

sub stats : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub stats_GET {
    my ($self, $c) = @_;

    my $total_amount_raised = $c->model("DB::Donation")->search({
        status       => "captured",
        by_votolegal => "t",
    })->get_column("amount")->sum || 0;

    my $candidates = $c->model("DB::Candidate")->search({
        status         => "activated",
        payment_status => "paid"
    })->count;

    my $total_people_donated = $c->model('DB::Donation')->search(
        {
            status       => "captured",
            by_votolegal => 't',
        },
        { group_by => "cpf" },
    )->count;

    my $total_donations = $c->model('DB::Donation')->search({
        status       => "captured",
        by_votolegal => 't',
    })->count;

    return $self->status_ok($c, entity => {
        total_amount_raised  => $total_amount_raised,
        candidates           => $candidates,
        total_people_donated => $total_people_donated,
        total_donations      => $total_donations,
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
