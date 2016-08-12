package VotoLegal::Controller::API::Candidate::Payment;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('payment') : CaptureArgs(0) {
    my ($self, $c) = @_;

    die \['status', "not activated"]         unless $c->stash->{candidate}->status eq "activated";
    die \['payment_status', "already paid."] unless $c->stash->{candidate}->payment_status eq "unpaid";

    $c->stash->{collection} = $c->model('DB::Payment');

    my $environment = is_test() ? 'sandbox' : 'production';
    my $auth        = $c->config->{pagseguro}->{$environment};

    $c->stash->{collection}->email($auth->{email});
    $c->stash->{collection}->token($auth->{token});
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
