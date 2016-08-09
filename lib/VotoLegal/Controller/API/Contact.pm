package VotoLegal::Controller::API::Contact;
use common::sense;
use Moose;
use namespace::autoclean;

use Data::Section::Simple qw(get_data_section);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('contact') : CaptureArgs(0) { }

sub contact : Chained('base') : Args(0) : PathPart('') {
    my ($self, $c) = @_;

    for (qw(name is_candidate email phone type message)) {
        die \[$_, "missing"] unless defined $c->req->params->{$_};
    }

    $c->req->params->{is_candidate} = $c->req->params->{is_candidate} ? "Sim" : "Não";

    my $email = VotoLegal::Mailer::Template->new(
        to       => $c->config->{sendmail}->{contact_to},
        from     => $c->config->{sendmail}->{default_from},
        subject  => "VotoLegal - Contato",
        template => get_data_section('contact.tt'),
        vars     => {
            user_agent => $c->req->user_agent || "N/A",
            map { $_ => $c->req->params->{$_} }
              qw(name is_candidate email phone type message)
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

@@ contact.tt

Nome: [% name %]
<br>
Candidato: [% is_candidate %]
<br>
Tipo do contato: [% type %]
<br>
Email: [% email %]
<br>
Telefone: [% phone %]
<br>
User-Agent: [% user_agent %]
<br><br>
Mensagem: [%message%]
