package VotoLegal::Controller::API::Login;
use Moose;
use namespace::autoclean;

use VotoLegal::Types qw(EmailAddress);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('login') : CaptureArgs(0) { }

sub login : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub login_POST {
    my ($self, $c) = @_;

    $c->req->params->{email} = lc $c->req->params->{email};

    $self->validate_request_params(
        $c,
        email => {
            type     => EmailAddress,
            required => 1,
        },
        password => {
            type     => "Str",
            required => 1,
        },
    );

    if ($c->authenticate($c->req->params)) {
        my $session = $c->user->new_session(
            %{$c->req->params},
            ip => $c->req->address,
        );

        # Barrando o login de candidatos que foram desaprovados.
        if (my $candidate = $c->user->candidates->next) {
            if ($candidate->status ne "deactivated") {
                $session->{signed_contract}      = $c->user->has_signed_contract();
                $session->{paid}                 = $candidate->candidate_has_paid();
                $session->{payment_created}      = $candidate->candidate_has_payment_created();
                $session->{address_state}        = $candidate->address_state;
                $session->{address_city}         = $candidate->address_city;
                $session->{address_zipcode}      = $candidate->address_zipcode;
                $session->{address_street}       = $candidate->address_street;
                $session->{address_house_number} = $candidate->address_house_number;
                $session->{name}                 = $candidate->name;
                $session->{phone}                = $candidate->phone;
                $session->{email}                = $candidate->user->email;

                if ( my $payment = $candidate->payments->search(undef, { max => 'created_at' } )->next ) {
                    $session->{payment_method} = $payment->method;
                }

                # Forçando retorno do valor
                my $value;
                if ( $candidate->political_movement_id == 1 ) {
                    $value = '247.50';
                }
                elsif ( $candidate->party_id == 34 || ( $candidate->political_movement_id && $candidate->political_movement_id =~ /^(2|3|4|5)$/ ) ) {
                    $value = '396.00';
                }
                else {
                    $value = '495.00';
                }

                $session->{amount} = $value;

                return $self->status_ok($c, entity => $session);
            }
        }
        else {
            # Se não for candidato, é admin.
            return $self->status_ok($c, entity => $session);
        }
    }

    return $self->status_bad_request($c, message => 'Bad email or password.');
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
