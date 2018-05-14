package WebService::IuguForReal;
use strict;
use utf8;
use MooseX::Singleton;

use VotoLegal::Logger;
use Furl;
use URI;
use MIME::Base64 qw(encode_base64);
use JSON::MaybeXS qw(encode_json decode_json);
use Carp 'croak';

BEGIN {
    use VotoLegal::Utils qw/is_test/;

    if ( !is_test() || $ENV{TEST_IUGU} ) {
        die "Missing IUGU_API_IS_TEST" unless $ENV{IUGU_API_IS_TEST};
        die "Missing IUGU_API_KEY"     unless $ENV{IUGU_API_KEY};
        die "Missing IUGU_ACCOUNT_ID"  unless $ENV{IUGU_ACCOUNT_ID};
        die "Missing IUGU_API_URL"     unless $ENV{IUGU_API_URL};

        $ENV{IUGU_MOCK} = 0;
    }
    else {
        $ENV{IUGU_MOCK}        = 1;
        $ENV{IUGU_API_IS_TEST} = 1;
        $ENV{IUGU_API_KEY}     = 'Fooba';
        $ENV{IUGU_ACCOUNT_ID}  = 'Fooba';
        $ENV{IUGU_API_URL}     = 'http://foobar.com';

    }
}

has ua => ( is => "rw", isa => "Furl", builder => '_build_ua', lazy => 1, );

my $domain = URI->new( $ENV{IUGU_API_URL} );

sub _build_ua {
    my $self = shift;

    Furl->new(
        timeout => 30,
        headers => [ Authorization => 'Basic ' . encode_base64( $ENV{IUGU_API_KEY} . ':' ) ]
    );

}

sub uri_for {
    my $self = shift;
    my $uri  = $domain->clone;
    $uri->path_segments( 'v1', @_ );
    return $uri;
}

sub create_invoice {
    my ( $self, %opts ) = @_;
    my $logger = get_logger;

    defined $opts{$_} or croak "missing $_" for qw/
      due_date
      donation_id
      is_boleto
      payer
      description
      amount
      /;

    my ( $data, $body, $post_url );
    Log::Log4perl::NDC->remove();

    Log::Log4perl::NDC->push( "create_invoice donation_id=" . $opts{donation_id} . '  ' );

    if ( !$ENV{IUGU_MOCK} ) {
        # checando se credit_card.two_step_transaction está habilitado
        if ( !$opts{is_boleto} ) {
            $logger->info("validating two_step_transaction...");
            my $res = $self->ua->get( $self->uri_for( 'accounts', $ENV{IUGU_ACCOUNT_ID} ),
                [ 'Content-Type' => "application/json", ] );

            my $json = decode_json( $res->decoded_content )
              or croak 'create_invoice failed';

            die 'credit_card.two_step_transaction precisa estar habilitada na Iugu'
              unless $json->{configuration}
              && $json->{configuration}->{credit_card}->{two_step_transaction};
        }

    }

    $post_url = $self->uri_for('invoices');
    $data     = {
        email        => $opts{donation_id} . '@no-email.com',
        payer        => $opts{payer},
        due_date     => $opts{due_date},
        payable_with => $opts{is_boleto} ? 'bank_slip' : 'credit_card',
        items        => [
            {
                description => $opts{description},
                quantity    => 1,
                price_cents => $opts{amount},
            }
        ],

    };
    $body = encode_json($data);
    $logger->info("create_invoice: POST $post_url\n$body");

    # criando invoice
    my $invoice;
    if ( $ENV{IUGU_MOCK} ) {

        $invoice = $VotoLegal::Test::Further::iugu_invoice_response;
    }
    else {
        my $res = $self->ua->post( $post_url, [ 'Content-Type' => "application/json", ], $body );
        $logger->info( "Iugu response: " . $res->decoded_content );

        $invoice = decode_json( $res->decoded_content )
          or croak 'create_invoice parse json failed';
    }

    croak "cannot create charge right now" unless $invoice->{id};

    # em caso de cartao, inicia-se o pagamento

    if ( !$opts{is_boleto} ) {
        $data = {
            token                   => $opts{credit_card_token},
            restrict_payment_method => \1,
            invoice_id              => $invoice->{id},
        };
        $body = encode_json($data);

        $post_url = $self->uri_for('charge');
        $logger->info("create_invoice: POST $post_url\n$body");

        if ( $ENV{IUGU_MOCK} ) {

            # nothing to do here
        }
        else {
            my $res = $self->ua->post( $post_url, [ 'Content-Type' => "application/json", ], $body );

            $logger->info( "Iugu response: " . $res->decoded_content );

            my $json = decode_json( $res->decoded_content ) or croak "$post_url decode failed";
            croak "cannot create charge right now" unless @{ $json->{errors} };

            $invoice->{_charge_response_} = $json;
        }
    }

    return $invoice;
}

