package VotoLegal::Schema::ResultSet::FsmState;
use namespace::autoclean;

use VotoLegal::Logger;
use utf8;
use Moose;

use JSON qw/from_json/;
use Carp;

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

    my $last_change = '';
    if ($state_config) {
        my @messages = $self->_messages_of_state(%opts);
      REPEAT:
        if ( $state_config->{auto_continue} ) {
            my $apply = $self->_apply(%opts);
            $opts{donation} = $apply->{newer_donation};

            push @messages, @{ $apply->{force_messages} || [] };

            $last_change  = $opts{donation}->state();
            $state_config = $config->{ $opts{donation}->state() };

            push @messages, $self->_messages_of_state(%opts);

            $max_auto_continues--;

            # still have something to do...
            goto REPEAT if $state_config->{auto_continue} && $max_auto_continues > 0;
        }

        $interface->{messages} = \@messages;

        # esse aqui precisa verificar a cada GET
        # uma coisa que precisa de lock
        if ( $opts{donation}->state() eq 'boleto_authentication' && $last_change ne 'boleto_authentication' ) {
            my $apply = $self->_apply(%opts);
            $opts{donation} = $apply->{newer_donation};

            push @messages, @{ $apply->{force_messages} || [] };

            $state_config = $config->{ $opts{donation}->state() };

            push @messages, $self->_messages_of_state(%opts);
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

                $new_stash = &on_state_enter( $donation, $new_stash, $current_state, $params );

            }

            $donation->set_new_state( $current_state, $new_stash );
        }
    );

    return { newer_donation => $donation, force_messages => $force_messages, prepend_messages => $prepend_messages };
}

sub on_state_enter {
    my ( $donation, $new_stash, $entering_state, $params ) = @_;

    if ( $entering_state eq 'waiting_boleto_authention' ) {


            $donation->_create_invoice();


    }elsif($entering_state eq 'credit_card_form' ){


        $donation->_generate_payment_credit_card();

    }

    return $new_stash;
}

sub _messages_of_state {
    my ( $self, %opts ) = @_;
    my @messages = ();

    my $loc = $opts{loc};

    my $config = $self->state_configuration( $opts{class} );

    my $state = $opts{donation}->state();
    my $state_config = $config->{$state} || croak "_messages_of_state called for bugous state '$state'";

    if ( $state eq 'credit_card_form' ) {

        my $donation = $opts{donation};

        my $info = $donation->payment_info_parsed;
        use DDP;
        p $donation;

        @messages = (
            {
                type => 'msg',
                text => $loc->('msg_add_credit_card'),
            },
            {
                ref     => 'credit_card_token',
                type    => 'credit_card_form/iugu',
                account_id => $info->{account_id},
                is_testing => $info->{is_testing},

            }
        );


    }

    return @messages;

}

sub _process_state {
    my ( $state, $loc, $donation, $params ) = @_;

    my $stash = $donation->stash_parsed();

    my @params = ( $state, $loc, $donation, $params, $stash );

    if ( $state eq 'created' ) {

        if ( $donation->is_boleto && $ENV{BOLETO_NEED_AUTHROIZATION} ) {
            $stash->{value} = 'BoletoWithAuth';
        }
        elsif ( $donation->is_boleto ) {
            $stash->{value} = 'BoletoWithoutAuth';
        }
        else {
            $stash->{value} = 'CreditCard';
        }

    }

    use DDP;
    p $stash;

    return $stash;
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

    return $interface;
}
1;
