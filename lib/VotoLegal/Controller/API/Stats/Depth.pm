package VotoLegal::Controller::API::Stats::Depth;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/stats/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('depth') : CaptureArgs(0) { }

sub depth : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub depth_GET {
    my ($self, $c) = @_;

    return $self->status_ok($c, entity => {
        donators => [
            $c->model("DB::Donation")->search(
                {
                    status       => "captured",
                    by_votolegal => "true",
                },
                {
                    select => [
                        { extract => \"year from created_at" },
                        { extract => \"month from created_at" },
                        { count => \"distinct(cpf)" },
                        { sum => "amount", -as => "amount" },
                    ],
                    as           => [ qw(year month count amount) ],
                    group_by     => [ { extract => \"month from created_at" }, { extract => \"year from created_at" } ],
                    result_class => "DBIx::Class::ResultClass::HashRefInflator",
                },
            )->all,
        ],
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
