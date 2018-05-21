package VotoLegal::Payment::Cielo;
use common::sense;
use Moose;

use JSON;
use Furl;
use Data::GUID;
use IO::Socket::SSL;
use Carp qw(croak);

with 'VotoLegal::Payment';

has merchant_id => (
    is       => "rw",
    required => 1,
);

has merchant_key => (
    is       => "rw",
    required => 1,
);

has sandbox => (
    is       => "rw",
    isa      => "Bool",
    required => 1,
);

has ua => (
    is      => "rw",
    isa     => "Furl",
    default => sub {
        Furl->new( ssl_opts => { SSL_verify_mode => SSL_VERIFY_NONE }, );
    },
    lazy => 1,
);

has payment_gateway_code => ( is => "rw", );

has logger => ( is => "rw", );

my $domains = {
    sandbox    => "https://apisandbox.cieloecommerce.cielo.com.br/1/",
    production => "https://api.cieloecommerce.cielo.com.br/1/",
};

sub tokenize_credit_card {
    my ( $self, %opts ) = @_;

    my $endpoint = $domains->{ $self->sandbox ? "sandbox" : "production" };

    # Tratando o campo 'ExpirationDate'.
    my $credit_card_validity       = $opts{credit_card_data}->{credit_card}->{validity};
    my $credit_card_validity_year  = substr( $credit_card_validity, 0, 4 );
    my $credit_card_validity_month = substr( $credit_card_validity, 4 );
    $credit_card_validity = $credit_card_validity_month . "/" . $credit_card_validity_year;

    # Enviando a request.
    my $req = $self->ua->post(
        $endpoint . "sales/",
        [
            'Content-Type' => "application/json",
            MerchantId     => $self->merchant_id,
            MerchantKey    => $self->merchant_key,
            RequestId      => Data::GUID->new->as_string,

        ],
        encode_json(
            {
                MerchantOrderId => $opts{order_data}->{id},
                Customer        => {
                    Name => $opts{order_data}->{name},
                },
                Payment => {
                    Type         => "CreditCard",
                    Amount       => $opts{order_data}->{amount},
                    Installments => 1,
                    CreditCard   => {
                        CardNumber     => $opts{credit_card_data}->{secret}->{number},
                        Holder         => $opts{credit_card_data}->{credit_card}->{name_on_card},
                        ExpirationDate => $credit_card_validity,
                        SecurityCode   => $opts{credit_card_data}->{secret}->{cvv},
                        Brand          => $self->_brand_to_bandeira( $opts{credit_card_data}->{credit_card}->{brand} ),
                    },
                },
            }
        ),
    );

    $self->logger->info( "Cielo: " . $req->content ) if $self->logger;

    if ( $req->is_success ) {
        my $json       = decode_json $req->content;
        my $returnCode = $json->{Payment}->{ReturnCode};

        # Tratando da resposta. Veja a lista completa dos códigos de retorno da Cielo em
        # http://developercielo.github.io/Webservice-3.0/#sandbox

        # Não autorizado.
        if ( grep { $returnCode == $_ } qw(2 77 70 78 57 99) ) {
            die \[ 'donation', "not authorized" ];
        }

        $self->payment_gateway_code( $json->{Payment}->{PaymentId} );
        return 1;
    }

    return 0;
}

sub do_authorization {
    my ($self) = @_;

    return 1;
}

sub do_capture {
    my ( $self, %opts ) = @_;

    croak "not tokenized" unless $self->payment_gateway_code;

    my $endpoint = $domains->{ $self->sandbox ? "sandbox" : "production" };

    my $req = $self->ua->put(
        $endpoint . "sales/" . $self->payment_gateway_code . "/capture",
        [
            'Content-Type' => "application/json",
            'MerchantId'   => $self->merchant_id,
            'MerchantKey'  => $self->merchant_key,
            'RequestId'    => Data::GUID->new->as_string,
        ],
        {},
    );
    $self->logger->info( "Cielo: " . $req->content ) if $self->logger;

    if ( $req->is_success ) {
        my $json = decode_json $req->content;

        if ( $json->{Status} == 2 ) {
            return 1;
        }
    }

    return 0;
}

sub _brand_to_bandeira {
    my ( $self, $brand ) = @_;

    my $from_to = {
        'visa'            => 'Visa',
        'mastercard'      => 'Master',
        'discover'        => 'Discover',
        'enroute'         => 'Diners',
        'jcb'             => 'JCB',
        'americanexpress' => 'Amex',
        'elo'             => 'Elo',
        'aura'            => 'Aura',
        'diners'          => 'Diners',
    };

    return $from_to->{$brand} || croak "brand '$brand' not supported by Cielo PaymentDriver";
}

__PACKAGE__->meta->make_immutable;

1
