package VotoLegal::Controller::API::Admin::CandidateWithDonationData;
use Moose;
use namespace::autoclean;

use DateTime::Format::Pg;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(

    # AutoBase.
    result => "DB::ViewDonationPeriod",
);

sub root : Chained('/api/admin/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('candidate-with-donation-data') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    return $self->status_ok(
        $c,
        entity => {
            candidates => [
                map {
                    my $raising_goal = $_->raising_goal;
                    $raising_goal =~ s/\./,/g;

                    my $goal_raised_percentage = $_->goal_raised_percentage . '%';
                    $goal_raised_percentage =~ s/\./,/g;

                    +{
                        id                     => $_->candidate_id,
                        name                   => $_->candidate_name,
                        party                  => $_->party,
                        raising_goal           => $raising_goal,
                        address_state          => $_->address_state,
                        donation_count         => $_->donation_count,
                        amount_raised          => $_->amount_raised,
                        avg_donation_amount    => $_->avg_donation_amount,
                        goal_raised_percentage => $goal_raised_percentage,
                        amount_boleto          => $_->amount_boleto ? $_->amount_boleto : '0',
                        amount_credit_card     => $_->amount_credit_card ? $_->amount_credit_card : '0'

                        # Deactivating these columns for now
                        # days_fund_raising => $_->days_fundraising,
                        # median_per_day    => $_->median_per_day,
                    }
                } $c->stash->{collection}->search()->all()
            ]
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
