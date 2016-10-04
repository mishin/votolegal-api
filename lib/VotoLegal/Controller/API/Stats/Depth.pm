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
        graph => [
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
                        { sum   => "amount", -as => "amount" },
                    ],
                    as           => [ qw(year month count amount) ],
                    group_by     => [ { extract => \"month from created_at" }, { extract => \"year from created_at" } ],
                    result_class => "DBIx::Class::ResultClass::HashRefInflator",
                },
            )->all,
        ],
        donors => (
            $c->model('DB::Donation')->search(
                {
                    status           => "captured",
                    donation_type_id => 1,
                },
                { group_by => "cpf" },
            ),
        )->count,
        total_amount => (
            $c->model('DB::Donation')->search({ status => "captured" })->get_column("amount")->sum || 0,
        ),
        total_party_fund => (
            $c->model('DB::Donation')->search( { donation_type_id => 2 })->get_column("amount")->sum || 0,
        ),
        total_credit_card => (
            $c->model('DB::Donation')->search({
                status       => "captured",
                by_votolegal => "true",
            })->get_column("amount")->sum || 0,
        ),
        total_electronic_transfer => (
            $c->model('DB::Donation')->search({
                species => "Transferência eletrônica",
            })->get_column("amount")->sum || 0,
        ),
        donations_up_to_hundred => (
            $c->model('DB::Donation')->search({
                amount => { '<=' => 10000 },
                status => "captured",
                donation_type_id => 1,
            })->count,
        ),
        donations_between_hundred_and_fivehundred => (
             $c->model('DB::Donation')->search({
                amount => { '>=' => 10000, '<=' => 50000 },
                status => "captured",
                donation_type_id => 1,
            })->count,
        ),
        donations_between_fivehundred_and_thousand => (
             $c->model('DB::Donation')->search({
                amount => { '>=' => 50000, '<=' => 100000 },
                status => "captured",
                donation_type_id => 1,
            })->count,
        ),
        donations_between_thousand_and_ten_thousand => (
             $c->model('DB::Donation')->search({
                amount => { '>=' => 100000, '<=' => 1000000 },
                status => "captured",
                donation_type_id => 1,
            })->count,
        ),
        donations_greater_than_ten_thousand => (
             $c->model('DB::Donation')->search({
                amount => { '>=' => 1000000 },
                donation_type_id => 1,
            })->count,
        ),
        candidates_allowed_transparency => (
            $c->model('DB::Candidate')->search({
                status         => "activated",
                payment_status => "paid",
            })->count,
        ),
        donations_through_votolegal => (
            $c->model('DB::Donation')->search({
                status       => "captured",
                by_votolegal => "true",
            })->count,
        ),
        donations_canceled => (
            $c->model('DB::Donation')->search({
                status => "canceled",
            })->count,
        ),
        candidates_received_via_credit_card => (
            $c->model('DB::Donation')->search({}, {
                columns  => [ qw(candidate_id) ],
                group_by => [ qw(candidate_id) ],
            })->count,
        ),
        donations_up_to_fifty_through_votolegal => (
            $c->model('DB::Donation')->search({
                amount       => { '<=' => 5000 },
                status       => "captured",
                by_votolegal => "true",
            })->count,
        ),
        donations_between_fifty_and_hundred_through_votolegal => (
            $c->model('DB::Donation')->search({
                amount       => { '>=' => 5000, '<=' => 10000 },
                status       => "captured",
                by_votolegal => "true",
            })->count,
        ),
        donations_between_hundred_and_fourhundred_through_votolegal => (
            $c->model('DB::Donation')->search({
                amount       => { '>=' => 10000, '<=' => 40000 },
                status       => "captured",
                by_votolegal => "true",
            })->count,
        ),
        donations_between_fourhundred_and_thousand_through_votolegal => (
            $c->model('DB::Donation')->search({
                amount       => { '>=' => 40000, '<=' => 106410 },
                status       => "captured",
                by_votolegal => "true",
            })->count,
        ),
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
