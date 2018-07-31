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
    my ( $self, $c ) = @_;

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

    if ( $c->authenticate( $c->req->params ) ) {
        my $session = $c->user->new_session( %{ $c->req->params }, ip => $c->req->address, );

        # Barrando o login de candidatos que foram desaprovados.
        if ( my $candidate = $c->user->candidates->next ) {
            if ( $candidate->status ne "deactivated" ) {
                $session->{signed_contract_campaign} = $c->user->has_signed_contract_campaign();
                $session->{signed_contract}          = $c->user->has_signed_contract_pre_campaign();
                $session->{paid}                     = $candidate->candidate_has_paid();
                $session->{payment_created}          = $candidate->candidate_has_payment_created();
                $session->{address_state}            = $candidate->address_state;
                $session->{address_city}             = $candidate->address_city;
                $session->{address_zipcode}          = $candidate->address_zipcode;
                $session->{address_street}           = $candidate->address_street;
                $session->{address_house_number}     = $candidate->address_house_number;
                $session->{name}                     = $candidate->name;
                $session->{phone}                    = $candidate->phone;
                $session->{email}                    = $candidate->user->email;
                $session->{campaign_donation_type}   = $candidate->campaign_donation_type;
                $session->{has_custom_site}          = $candidate->has_custom_site;

                if ( my $payment = $candidate->payments->search( undef, { max => 'created_at' } )->next ) {
                    $session->{payment_method} = $payment->method;
                }

                # Forçando retorno do valor
                my $value;
                if ( $candidate->political_movement_id ) {
                    if ( $candidate->political_movement_id == 1 ) {
                        $value = '148.50';
                    }
                    elsif ( $candidate->political_movement_id == 9 ) {
                        $value = '148.50';
                    }
                    elsif ( $candidate->party_id == 26 ) {
                        $value = '178.20';
                    }
                    elsif (( $candidate->party_id == 34 && $candidate->political_movement_id != 1 )
                        || ( $candidate->political_movement_id && $candidate->political_movement_id =~ /^(2|3|4|5|8)$/ ) )
                    {
                        $value = '237.60';
                    }
                }
                elsif ( $candidate->party_id == 26 ) {
                    $value = '178.20';
                }
                elsif ( $candidate->party_id == 4 ) {
                    $value = '237.00';
                }
				elsif ( $candidate->party_id == 4 && $candidate->address_state eq 'MT' ) {
					$value = '237.00';
				}
                elsif ( $candidate->party_id == 15 ) {
                    $value = '208.00';
                }
				elsif ( $candidate->party_id == 34 ) {
					$value = '237.60';
				}
                else {
                    $value = '297.00';
                }

                $session->{amount} = $value;

                return $self->status_ok( $c, entity => $session );
            }
        }
        else {
            # Se não for candidato, é admin.
            return $self->status_ok( $c, entity => $session );
        }
    }

    return $self->status_bad_request( $c, message => 'Bad email or password.' );
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
