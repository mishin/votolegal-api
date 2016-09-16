package VotoLegal::Controller::API::Candidate::Donation::Vote;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/donation/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::ProjectVote');
}

sub base : Chained('root') : PathPart('vote') : CaptureArgs(0) { }

sub vote : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub vote_POST {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        project_id => {
            required => 1,
            type     => "Str",
        },
    );

    # Por segurança, eu não exibo erro quando o id da doação é inválida.
    if (defined $c->stash->{donation}) {
        # Os votos repetidos devem ser ignorados. Para isso eu obtenho todos os existentes e filtro.
        my $donation_id = $c->stash->{donation}->id;

        my %exists = map { $_->project_id => 1 } $c->stash->{collection}->search({ donation_id => $donation_id })->all;
        my @project_ids = grep { !$exists{$_} } grep { int($_) == $_ } split(/,/, $c->req->params->{project_id});

        # Checando se há votos disponíveis.
        my $count = $c->stash->{collection}->search({ donation_id => $donation_id })->count;

        if ($count + scalar(@project_ids) > 3) {
            die \["donation_id", "max votes reached"];
        }

        for my $project_id (@project_ids) {
            $c->stash->{collection}->create({
                donation_id => $donation_id,
                project_id  => $project_id,
            });
        }
    }

    return $self->status_ok($c, entity => { message => "ok" });
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
