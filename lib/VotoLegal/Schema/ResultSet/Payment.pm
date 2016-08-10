package VotoLegal::Schema::ResultSet::Payment;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'VotoLegal::Role::Verification';

use Furl;
use XML::Simple;
use Data::Verifier;

has email => (
    is  => "rw",
    isa => "Str",
);

has token => (
    is  => "rw",
    isa => "Str",
);

has _ua => (
    is      => "rw",
    isa     => "Furl",
    default => sub { Furl->new() },
    lazy    => 1,
);

has _endpoint => (
    is      => "rw",
    isa     => "Str",
    default => "https://ws.sandbox.pagseguro.uol.com.br/v2/",
    lazy    => 1,
);

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                senderHash => {
                    type     => 'Str',
                    required => 1,
                },
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            return $self->create(\%values);
        },
    };
}

sub newSession {
    my ($self) = @_;

    my $req = $self->_ua->post(
        $self->_endpoint . "sessions",
        [],
        {
            email => $self->email,
            token => $self->token,
        }
    );

    if ($req->is_success()) {
        my $xml = XMLin($req->content);

        if (ref $xml eq "HASH") {
            return $xml->{id};
        }
    }

    return ;
}

sub getBoleto {
    my ($self, %params) = @_;

    my $req = $self->_ua->post(
        $self->_endpoint . "transactions/",
        [],
        {
            %params,
            email                  => $self->email,
            token                  => $self->token,
            paymentMode            => "default",
            paymentMethod          => "boleto",
            receiverEmail          => 'renato.pacheco@eokoe.com',
            currency               => "BRL",
            extraAmount            => "0.00",
            itemId1                => "0001",
            itemDescription1       => "Pagamento VotoLegal",
            itemAmount1            => "99.00",
            itemQuantity1          => "1",
            shippingAddressCountry => "BRA",
            notificationURL        => "https://hookb.in/va3nxWgn",
        }
    );

    if ($req->is_success()) {
        my $xml = XMLin($req->content);

        if (ref $xml eq "HASH") {
            return $self->create({
                code         => $xml->{code},
                candidate_id => $params{reference},
                sender_hash  => $params{senderHash},
                boleto_url   => $xml->{paymentLink},
            });
        }
    }

    return ;
}

#__PACKAGE__->meta->make_immutable;

1;

