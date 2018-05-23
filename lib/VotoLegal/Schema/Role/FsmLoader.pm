package VotoLegal::Schema::Role::FsmLoader;
use namespace::autoclean;

use Moose::Role;
use Readonly;

use feature 'state';
use FSM::Simple;
use JSON::XS;

requires 'resultset';
requires '_process_state';

sub _decode_json_fields {
    my ($hash) = @_;
    $hash->{auto_continue} = $hash->{auto_continue} ? 1 : 0;
    return $hash;
}

sub _get_fms_simple {
    my ( $self, $class, $loc ) = @_;

    state $_cache;

    if ( !$_cache->{$class} ) {

        my @states = keys %{ $self->state_configuration($class) || {} };

        my $machine = FSM::Simple->new();

        foreach my $state_name (@states) {
            $machine->add_state(
                name => $state_name,
                sub  => sub {
                    return VotoLegal::Schema::ResultSet::FsmState::_process_state( $state_name, $loc, @_ );
                }
            );
        }

        my @trans = $self->resultset('FsmTransition')->search(
            { fsm_class => $class },
            {
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            }
        )->all;

        foreach my $transition (@trans) {
            $machine->add_trans(
                from    => $transition->{from_state},
                to      => $transition->{to_state},
                exp_val => $transition->{transition}
            );
        }

        $_cache->{$class} = $machine;
    }

    return $_cache->{$class};

}

sub state_configuration {
    my ( $self, $class ) = @_;

    state $_cache;

    if ( !$_cache->{$class} ) {

        my $opt;
        Readonly::Scalar $opt => {
            map { $_->{name} => _decode_json_fields($_) } $self->resultset('FsmState')->search(
                { fsm_class => $class },
                {
                    result_class => 'DBIx::Class::ResultClass::HashRefInflator'
                }
            )->all
        };

        $_cache->{$class} = $opt;
    }

    return $_cache->{$class};

}

sub _draw_machine {
    my ( $self, %opts ) = @_;

    my $fms_simple = $self->_get_fms_simple( $opts{class} );

    my $sc = $self->state_configuration( $opts{class} );

    sub generate_graphviz_code {
        my ( $sc, $self, %args ) = @_;
        my $graph_name = $args{name} || 'finite_state_machine';
        my $size = '960';

        my $transitions = '';
        foreach my $rh_trans ( sort { $a->{from} . $a->{to} cmp $b->{from} . $b->{to} } $self->trans_array ) {
            my $color =
                $rh_trans->{returned_value} =~ /^\@/    ? ' color = "#FF1111"'
              : $rh_trans->{returned_value} =~ /^\#/    ? 'color = "#00cc1e"'
              : $rh_trans->{returned_value} =~ /GiveUP/ ? 'color = "#FF8000"'
              :                                           '';

            $color = 'color = "#00cc1e"' if $sc->{ $rh_trans->{from} }{auto_continue};

            $transitions .= sprintf "    %s -> %s [ label = \"%s\" $color];\n", $rh_trans->{from}, $rh_trans->{to},
              $rh_trans->{returned_value};
        }

        my $graphviz_code = qq|
digraph $graph_name {
    rankdir=LR;
    size="$size";
    node [shape = doublecircle]; created;
    node [shape = circle];
    node [color = "#000000"];

    $transitions

    not_authorized, boleto_expired [
        color="black",
        fillcolor="#ffbfc6",
        style="filled,solid"
    ];
    wait_for_compensation [
        color="black",
        fillcolor="#68ffa7",
        style="filled,solid"
    ];

    capture_cc, validate_payment [
        color="black",
        fillcolor="#60afff",
        style="filled,solid"
    ];
    refunded, error_manual_check [
        color="black",
        fillcolor="#ffd6bf",
        style="filled,solid"
    ];

    { rank=same refunded error_manual_check }

    { rank=same capture_cc validate_payment not_authorized boleto_expired}
    { rank=same boleto_authentication credit_card_form}


}
    |;

        use DDP;
        p $graphviz_code;
        return $graphviz_code;
    }
    my $x = &generate_graphviz_code( $sc, $fms_simple, size => 96 );
    open my $fx, '>:raw', '/tmp/fsm';
    print $fx $x;
    close $fx;
    my $name = "/tmp/votolegal-payment.svg";

    `cat /tmp/fsm | dot -Tsvg > $name`;

    return $name;
}

1;
