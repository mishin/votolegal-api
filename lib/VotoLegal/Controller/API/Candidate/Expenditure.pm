package VotoLegal::Controller::API::Candidate::Expenditure;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    if ($c->stash->{candidate}->status ne "activated") {
        $self->status_bad_request($c, message => "candidato não aprovado.");
        $c->detach();
    }

    $c->stash->{collection} = $c->stash->{candidate}->expenditures;
}

sub base : Chained('root') : PathPart('expenditure') : CaptureArgs(0) { }

sub expenditure : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub expenditure_GET {
    my ($self, $c) = @_;

    my $page    = $c->req->params->{page}    || 1;
    my $results = $c->req->params->{results} || 20;

    # O candidato vê apenas doações do VotoLegal.
    my @expenditures = $c->stash->{collection}->search(
        undef,
        {
            select       => [ "name", "cnpj", { sum => "amount", '-as' => "amount" } ],
            as           => [ qw(name cnpj amount) ],
            group_by     => [ qw(name cnpj) ],
            order_by     => { '-desc' => "amount" },
            page         => $page,
            rows         => $results,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all();

    return $self->status_ok(
        $c,
        entity => {
            expenditure => \@expenditures,
        }
    );
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
