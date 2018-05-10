package VotoLegal::Schema::Role::ResultsetFind;

use Moose::Role;

sub resultset_find {
    my ( $res, @find ) = @_;
    $res->result_source->schema->resultset( $res->result_source->source_name )->find(@find);
}

sub resultset_search {
    my ( $res, @find ) = @_;
    $res->result_source->schema->resultset( $res->result_source->source_name )->search(@find);
}

sub resultset {
    my ( $res, @a ) = @_;
    $res->result_source->schema->resultset(@a);
}

sub epoch_to_ts {
    my ( $self, $epoch ) = @_;

    die 'invalid epoch' unless $epoch =~ /^[0-9]{9,13}$/;
    if ( $epoch && length $epoch == 13 ) {
        $epoch /= 1000;
    }
    elsif ( $epoch && length $epoch == 12 ) {
        $epoch /= 100;
    }
    elsif ( $epoch && length $epoch == 11 ) {
        $epoch /= 10;
    }

    my $x = $self->result_source->schema->storage->dbh->quote($epoch);
    $x = "TIMESTAMP WITH TIME ZONE 'epoch' + $x * INTERVAL '1 second'";

    return \$x;
}

1;

