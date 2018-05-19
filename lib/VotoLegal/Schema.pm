use utf8;
package VotoLegal::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-16 23:31:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Oy58CXNLp/hwPdWXRdMEQw

sub AUTOLOAD {
    ( my $name = our $AUTOLOAD ) =~ s/.*:://;
    no strict 'refs';

    # isso cria na hora a sub e não é recompilada \m/ perl nao é lindo?!
    *$AUTOLOAD = sub {
        my ( $self, @args ) = @_;
        my $res = eval {
            $self->storage->dbh->selectrow_hashref( "select * from $name ( " . substr( '?,' x @args, 0, -1 ) . ')',
                undef, @args );
        };
        do { print $@; return undef } if $@;
        return $res;
    };
    goto &$AUTOLOAD;
}

sub set_config {
    my ( $self, $key, $value ) = @_;

    $self->txn_do(
        sub {

            my $look = $self->resultset('Config')->search( { name => $key } );
            $look->update( { valid_to => \'NOW()' } );
            $look->create( { value => $value } );
        }
    );

}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
