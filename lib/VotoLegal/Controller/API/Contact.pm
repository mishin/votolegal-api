package VotoLegal::Controller::API::Contact;
use Moose;
use namespace::autoclean;

use Data::Section::Simple qw(get_data_section);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('contact') : CaptureArgs(0) { }

sub contact : Chained('base') : PathPart('') {
    my ($self, $c) = @_;

    for (qw(name email message)) {
        die \[$_, "missing"] unless defined $c->req->params->{$_};
    }

    my $email = VotoLegal::Mailer::Template->new(
        to       => $c->config->{email}->{contact_to},
        from     => $c->config->{email}->{default_from},
        subject  => "VotoLegal - Contato",
        template => get_data_section('contact.tt'),
        vars     => { map { $_ => $c->req->params->{$_} } qw(name phone email message) }
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

Nome: [%name%]
<br>
Email: [%email%]
<br>
Telefone: [%phone%]
<br><br>
Mensagem: [%message%]
