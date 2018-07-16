package VotoLegal::Schema::ResultSet::FsmState;
use namespace::autoclean;

use VotoLegal::Logger;
use utf8;
use Moose;

use JSON::XS;
use JSON qw/from_json/;
use Carp;
use VotoLegal::Utils qw/is_test/;
use Digest::SHA qw(sha1_hex);

extends 'DBIx::Class::ResultSet';
with 'VotoLegal::Schema::Role::ResultsetFind';
with 'VotoLegal::Schema::Role::FsmLoader';

my $supports;

sub interface {
    my ( $self, %opts ) = @_;

    $supports = $opts{supports} || die 'missing supports';
    $opts{time_zone} = 'America/Sao_Paulo';    # brasilia segue SP

    my %other;
    my $loc = $opts{loc};

    my $config    = $self->state_configuration( $opts{class} );
    my $interface = {};

    my $max_auto_continues = 10;
    my $state_config       = $config->{ $opts{donation}->state() };

    my $last_applied_state = '';
    if ($state_config) {
        my @messages = $self->_messages_of_state(%opts);
      REPEAT:
        if ( $state_config->{auto_continue} ) {
            my $apply = $self->_apply(%opts);
            $opts{donation} = $apply->{newer_donation};

            push @messages, @{ $apply->{force_messages} || [] };

            $last_applied_state = $opts{donation}->state();
            $state_config       = $config->{ $opts{donation}->state() };

            push @messages, $self->_messages_of_state(%opts);

            $max_auto_continues--;

            # still have something to do...
            goto REPEAT if $state_config->{auto_continue} && $max_auto_continues > 0;
        }

        $interface->{messages} = \@messages;

        # em alguns estados, precisa escrever no banco durante um GET
        # entao precisa chamar o _apply
        for my $apply_on_get_state (qw/boleto_authentication waiting_boleto_payment wait_for_compensation/) {

            if ( $opts{donation}->state() eq $apply_on_get_state && $last_applied_state ne $apply_on_get_state ) {
                undef @messages;
                my $apply = $self->_apply(%opts);
                $opts{donation} = $apply->{newer_donation};

                push @messages, @{ $apply->{force_messages} || [] };

                $state_config = $config->{ $opts{donation}->state() };

                if ( $state_config->{auto_continue} ) {
                    goto REPEAT;
                }
                else {

                    push @messages, $self->_messages_of_state(%opts);
                }

                # se aplicou, vai embora, pois só tem como ter um state por vez
                last;
            }
        }

    }

    if ( !$state_config || !$max_auto_continues ) {
        log_error($@) if $@;

        $interface->{messages} = [
            {
                type => 'msg',
                text => !$max_auto_continues
                ? $loc->('msg_internal_we_are_in_loop')
                : $loc->('msg_internal_error_try_again')
            },
            {
                type => 'msg',
                text => $loc->('msg_sorry')
            },
        ];

    }

    $other{donation} = $opts{donation}->as_row();

    return { ui => $interface, %other };
}

sub _apply {
    my ( $self, %opts ) = @_;

    my $fms_simple = $self->_get_fms_simple( $opts{class}, $opts{loc} );

    my $donation;
    my $force_messages;
    my $prepend_messages;

    die 'transaction_depth is wrong' if !is_test && $self->result_source->storage->transaction_depth > 0;

    $self->result_source->schema->txn_do(
        sub {
            $donation = $opts{donation}->obtain_lock();

            my $current_state = $donation->state();

            my $params = $opts{params} || {};

            my $new_stash = $fms_simple->{states}{$current_state}{sub_to_run}( $donation, $params );
            my $result = delete $new_stash->{value};

            $force_messages   = delete $new_stash->{messages};
            $prepend_messages = delete $new_stash->{prepend_messages};

            if ($result) {

                unless ( exists $fms_simple->{states}{$current_state}{transitions}{$result} ) {
                    croak "Next state is not defined for value '$result'. Choose one from: " . join ' ',
                      keys( %{ $fms_simple->{states}{$current_state}{transitions} } );
                }

                $current_state = $fms_simple->{states}{$current_state}{transitions}{$result};

                # atualiza a stash antes de ir chamar o on_state_enter
                $donation->set_new_state( $current_state, $new_stash );

                $new_stash = &on_state_enter( $donation, $new_stash, $current_state, $params );

                # salva a stash novamente se mudou algo
                $donation->set_new_state( $current_state, $new_stash ) if $new_stash;

            }
            else {

                $donation->set_new_state( $current_state, $new_stash );
            }
        }
    );

    return { newer_donation => $donation, force_messages => $force_messages, prepend_messages => $prepend_messages };
}

sub on_state_enter {
    my ( $donation, $new_stash, $entering_state, $params ) = @_;

    if ( $entering_state eq 'waiting_boleto_payment' ) {

        $donation->_create_invoice();

    }
    elsif ( $entering_state eq 'credit_card_form' ) {

        $donation->_generate_payment_credit_card();

    }
    elsif ( $entering_state eq 'start_cc_payment' ) {

        $donation->_create_invoice();

    }
    elsif ( $entering_state eq 'boleto_authentication' ) {

        $donation->generate_certiface_link();
    }
    elsif ( $entering_state eq 'refunded' ) {

        my $info = $donation->payment_info_parsed;

        $donation->update({
            refunded_at => $info->{updated_at_iso}
        });

    }

    else {
        return undef;
    }

    return $new_stash;
}

sub _messages_of_state {
    my ( $self, %opts ) = @_;
    my @messages = ();

    my $loc = $opts{loc};

    my $config = $self->state_configuration( $opts{class} );

    my $state        = $opts{donation}->state();
    my $state_config = $config->{$state} || croak "_messages_of_state called for bugous state '$state'";
    my $donation     = $opts{donation};
    $donation->discard_changes;

    if ( $state eq 'credit_card_form' ) {

        my $info = $donation->payment_info_parsed;

        @messages = (
            {
                type => 'msg',
                text => $loc->('msg_add_credit_card'),
            },
            {
                ref        => 'credit_card_token',
                type       => 'credit_card_form/iugu',
                account_id => $info->{account_id},
                is_testing => $info->{is_testing},

            }
        );
    }
    elsif ( $state eq 'waiting_boleto_payment' ) {

        my $candidate_config_id = $donation->candidate->emaildb_config_id;

        my $info = $donation->payment_info_parsed;
        my $text_boleto = $loc->('msg_boleto_message');

        if ( $candidate_config_id == 2 ) {
            $text_boleto = $loc->('msg_boleto_2_message');
        }

        my $due_date_br = DateTime::Format::Pg->parse_datetime( $donation->payment_info_parsed->{due_date} )->dmy('/');
        $text_boleto =~ s/__DUE_DATE__/$due_date_br/;

        @messages = (
            {
                type => 'msg',
                text => $text_boleto,
            },
            {
                type => 'link',
                text => $loc->('msg_boleto_link'),
                href => $info->{secure_url},
            },
            ( $candidate_config_id == 2 ?
              (
                  {
                      type => 'link',
                      text => $loc->('feedback_form_text_2'),
                      href => $loc->('feedback_form_url_2')
                  }
              ) : ( )
            )
        );

    }
    elsif ( $state eq 'boleto_authentication' ) {

        @messages = (
            {
                type => 'msg',
                text => $loc->('msg_text_certiface'),
            },
            {
                type => 'link',
                text => $loc->('msg_link_certiface'),
                href => $donation->current_certiface->verification_url,
            }
        );

    }
    elsif ( $state eq 'certificate_refused' ) {

        @messages = (
            {
                type => 'msg',
                text => $loc->('msg_certificate_refused'),
            },
            {
                type  => 'button',
                text  => $loc->('btn_pay_with_cc'),
                value => 'pay_with_cc'
            }
        );

    }
    elsif ( $donation->refunded_at ) {

        @messages = (
            {
                type => 'msg',
                text => $loc->('msg_refunded_message'),
            },
        );

    }
    elsif ( $donation->captured_at ) {

		my $candidate_config_id = $donation->candidate->emaildb_config_id;

        my $info = $donation->payment_info_parsed;

        my $text;

        @messages = (
            {
                type => 'msg',
                text => $donation->is_boleto ? $loc->('msg_boleto_paid_message') : ( $candidate_config_id == 2 ? $loc->('msg_cc_paid_message_2') : $loc->('msg_cc_paid_message') ),
            },
            # ( $candidate_config_id == 2 ?
            #   (
            #       {
            #           type => 'link',
            #           text => $loc->('feedback_form_text_2'),
            #           href => $loc->('feedback_form_url_2')
            #       }
            #   ) : ( )
            # )
        );

    }

    return @messages;
}

sub _process_state {
    my ( $state, $loc, $donation, $params ) = @_;

    my $stash = $donation->stash_parsed();

    my @params = ( $state, $loc, $donation, $params, $stash );

    if ( $state eq 'created' ) {

        &_process_created(@params);

    }
    elsif ( $state eq 'credit_card_form' ) {

        &_process_credit_card_form(@params);

    }
    elsif ( $state eq 'start_cc_payment' ) {
        &_process_start_cc_payment(@params);

    }
    elsif ( $state eq 'capture_cc' ) {
        &_process_capture_cc(@params);

    }
    elsif ( $state eq 'waiting_boleto_payment' ) {
        &_process_waiting_boleto_payment(@params);

    }
    elsif ( $state eq 'validate_payment' ) {
        &_process_validate_payment(@params);

    }
    elsif ( $state eq 'boleto_authentication' ) {
        &_process_boleto_authentication(@params);

    }
    elsif ( $state eq 'certificate_refused' ) {
        &_process_certificate_refused(@params);

    }
    elsif ( $state eq 'wait_for_compensation' ) {
        &_process_wait_for_compensation(@params);

    }

    return $stash;
}

sub _process_wait_for_compensation {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    $donation = $donation->sync_gateway_status();

    my $info = $donation->payment_info_parsed;

    if ( $info->{status} eq 'chargeback' ) {
        $stash->{value} = 'refunded';
    }
}

sub _process_certificate_refused {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    if ( exists $params->{action_id} && $params->{action_id} eq 'pay_with_cc' ) {
        $stash->{value} = 'pay_with_cc';
        return;
    }

}

sub _process_boleto_authentication {

    my ( $state, $loc, $donation, $params, $stash ) = @_;
    my $certiface = $donation->current_certiface();

    if ( $certiface->process_response_and_validate() == 0 ) {

        # se o link expirou ou deu 404 no get
        # atualiza o link

        $donation->generate_certiface_link();

    }
    else {

        if ( $certiface->validated ) {

            $stash->{value} = 'human_verified';

        }
        else {

            $stash->{value} = 'not_human';

        }
    }

}

sub _process_waiting_boleto_payment {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    $donation = $donation->sync_gateway_status();

    my $info = $donation->payment_info_parsed;

    if ( $info->{status} eq 'paid' ) {
        $stash->{value} = 'boleto_paid';
    }
    elsif ( $info->{status} eq 'expired' ) {
        $stash->{value} = 'due_reached';

        $donation->send_boleto_expired_email();
    }

}

sub _process_validate_payment {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    my $info = $donation->payment_info_parsed;

    if ( $info->{total_paid_cents} == $donation->votolegal_donation_immutable->amount ) {

        $donation->set_boleto_paid;

        $stash->{value} = 'paid_amount_ok';

    }
    else {
        $stash->{value} = 'not_acceptable';
    }
}

sub _process_start_cc_payment {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    my $info = $donation->payment_info_parsed;

    my $success = $info->{_charge_response_}{'LR'} eq '00';

    if ($success) {

        $stash->{value} = 'cc_authorized';

        $stash->{messages} = [
            {
                type => 'msg',
                text => $loc->('msg_cc_authorized'),
            }
        ];

    }
    else {

        $stash->{value} = 'cc_not_authorized';

        $stash->{messages} = [
            {
                type => 'msg',
                text => $loc->('msg_cc_not_authorized'),
            }
        ];
    }

}

sub _process_capture_cc {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    eval { $donation->capture_cc };
    my $err = $@;
    if ($err) {
        $stash->{capture_error_message} = $err;
    }

    $stash->{value} = $err ? 'error' : 'captured';

    if ( $stash->{value} eq 'captured' ) {
        $donation->result_source->schema->resultset('EmaildbQueue')->create(
            {
                config_id => $donation->candidate->emaildb_config_id,
                template  => 'captured.html',
                to        => $donation->votolegal_donation_immutable->donor_email,
                subject   => $loc->( 'email_' . $donation->candidate->emaildb_config_id . '_captured_subject' ),
                variables => encode_json( $donation->as_row_for_email_variable() ),
            }
        );
    }

}

sub _process_credit_card_form {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    if ( !$params->{credit_card_token} ) {

        $stash->{prepend_messages} = [
            {
                type  => 'msg',
                style => 'error',
                text  => $loc->('msg_invalid_cc_token'),
            }
        ];
        return;
    }
    if ( !$params->{cc_hash} ) {

        $stash->{prepend_messages} = [
            {
                type  => 'msg',
                style => 'error',
                text  => $loc->('msg_invalid_cc_hash'),
            }
        ];
        return;
    }
    $stash->{cc_hash} = sha1_hex( $params->{cc_hash} );

    $stash->{credit_card_token} = $params->{credit_card_token};
    $stash->{value}             = 'credit_card_added';
}

sub _process_created {
    my ( $state, $loc, $donation, $params, $stash ) = @_;

    if ( $donation->is_boleto && $ENV{CERTIFICATE_ENABLED} && $donation->candidate->use_certiface ) {

        if ( $donation->device_authorization_token->can_create_boleto_without_certiface ) {

            $stash->{value} = 'BoletoWithoutAuth';

        }
        else {
            $stash->{value} = 'BoletoWithAuth';
        }
    }
    elsif ( $donation->is_boleto ) {
        $stash->{value} = 'BoletoWithoutAuth';
    }
    else {
        $stash->{value} = 'CreditCard';
    }
}

sub shift_until_input {
    my ( $ref, $field ) = @_;

    my @messages;

    my $arrayref = $ref->{$field};
    croak "\$stash->{$field} must be an array" unless ref $arrayref eq 'ARRAY';

    while ( my $msg = shift @{$arrayref} ) {
        push @messages, $msg;

        last if ( $msg->{type} =~ /^(selection|text)/ );
    }

    return wantarray ? @messages : \@messages;
}

sub apply_interface {
    my ( $self, %opts ) = @_;

    $supports = $opts{supports} || die 'missing supports';
    my @messages;

    my $interface;
    my $interface_ui;
    my $apply = eval { $self->_apply(%opts) };
    if ($@) {
        log_error($@);
        $interface->{ui}{messages} = [
            {
                type => 'msg',
                text => $opts{loc}->('msg_internal_error_try_again')
            },
            {
                type => 'msg',
                text => $opts{loc}->('msg_sorry')
            },
        ];

    }
    else {

        $opts{donation} = $apply->{newer_donation};
        push @messages, @{ $apply->{messages} || [] };

        $interface    = $self->interface(%opts);
        $interface_ui = $interface->{ui};

        if ( exists $apply->{force_messages} && defined $apply->{force_messages} ) {

            $interface_ui->{messages} = $apply->{force_messages};

        }
        else {

            $interface_ui->{messages} = [ @messages, @{ $interface_ui->{messages} || [] } ];
        }
    }

    $interface_ui->{messages} = [ @{ $apply->{prepend_messages} }, @{ $interface_ui->{messages} } ]
      if exists $apply->{prepend_messages} && defined $apply->{prepend_messages};

    $interface->{donation} = $opts{donation}->as_row();
    return $interface;
}
1;
