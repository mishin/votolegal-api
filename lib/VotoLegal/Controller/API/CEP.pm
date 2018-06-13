package VotoLegal::Controller::API::CEP;
use Moose;
use utf8;
use JSON::XS;

use VotoLegal::Types qw(CEP);
use VotoLegal::Dieable;

use WebService::CEP;
use MooseX::Types::Moose qw(Int);

BEGIN { extends 'CatalystX::Eta::Controller::REST'; }

__PACKAGE__->config( cep_backends => [qw(Correios Postmon Viacep)] );

use namespace::autoclean -except => [qw(Int CEP)];

my $options;
my @_address_fields = qw(city state);

sub cep : Chained('/api/root') Path('cep') Args(0) GET Query( cep => 'Str' ) {
    my ( $self, $c ) = @_;

    $options ||= [ map { WebService::CEP->new_with_traits( traits => $_ ) } @{ $self->config->{cep_backends} } ];

    my $cep = to_CEP( $c->req->params->{cep} )
      or die { type => 'default', msg_id => 'missing_cep' };

    my $candidate;
    foreach my $cepper (@$options) {
        $cep =~ s/[^0-9]//go;

        if ( my $result = $cepper->find($cep) ) {
            $candidate = { backend => $cepper->name, result => $result };

            die \['CEP', 'CEP was dismembered, check on Correios website'] if $cep ne $result->{cep};

            # todos os campos preenchidos
            last if ( grep { length $result->{$_} } @_address_fields ) == @_address_fields;
        }
    }

    if ($candidate) {

        my $state = $c->model('DB::State')->search( { code => $candidate->{result}{state} } )->next;

        die_with 'state-not-found' unless $state;

        my $city = $state->cities->search( { name => $candidate->{result}{city} } )->next;
        unless ($city) {

            eval { $state->cities->search( { name => $candidate->{result}{city} } )->create( { cep => $cep } ) };
            die $@ if $@ && $@ !~ /city_pkey/;
        }

        $c->res->header( 'X-Cep-Backend' => $candidate->{backend} );
        $self->status_ok( $c, entity => $candidate->{result} );
        return 1;
    }

    $self->status_not_found( $c, message => 'CEP not found' );
}

sub state : Chained('/api/root') : PathPart('cep-states') CaptureArgs(0) {
}

sub list_states : Chained('state') : PathPart('') Args(0) GET {
    my ( $self, $c ) = @_;

    $self->status_ok(
        $c,
        entity => [
            $c->model('DB::State')->search_rs(
                undef,
                {
                    result_class => 'DBIx::Class::ResultClass::HashRefInflator',
                    order_by     => { -asc => 'code' }
                }
            )->all
        ]
    );
}

sub list_cities : Chained('state') : PathPart('') Args('Int') GET {
    my ( $self, $c, $id ) = @_;
    my $state = $c->model('DB::State')->find($id)
      or $self->status_not_found( $c, message => 'state not found' ), $c->detach;

    $self->status_ok(
        $c,
        entity => [
            $state->cities->search_rs(
                undef,
                {
                    result_class => 'DBIx::Class::ResultClass::HashRefInflator',
                    order_by     => { -asc => 'name' }
                }
            )->all
        ]
    );

}

__PACKAGE__->meta->make_immutable;

1;