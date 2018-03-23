package VotoLegal::Controller::API::Troubleshoot;
use common::sense;
use Moose;
use namespace::autoclean;

use Data::Section::Simple qw(get_data_section);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('troubleshoot') : CaptureArgs(0) { }

sub contact : Chained('base') : Args(0) : PathPart('') {
    my ($self, $c) = @_;

    for (qw(route error)) {
        die \[$_, "missing"] unless defined $c->req->params->{$_};
    }

    my $email = VotoLegal::Mailer::Template->new(
        to       => 'dev@votolegal.org.br',
        from     => $ENV{EMAIL_DEFAULT_FROM},
        subject  => "VotoLegal - Troubleshoot",
        template => get_data_section('troubleshoot.tt'),
        vars     => {
            route      => $c->req->params->{route},
            error      => $c->req->params->{error},
            user_agent => $c->req->user_agent || 'N/A',
        }
    )->build_email();

    my $queued = $c->model('DB::EmailQueue')->create({ body => $email->as_string });

    return $self->status_ok($c, entity => { id => $queued->id });
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

__DATA__

@@ troubleshoot.tt

Rota: [% route %]
<br>
User-Agent: [% user_agent %]
<br>
Erro: [% error %]
