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
        die "Missing IUGU_API_TEST_MODE"                unless defined $ENV{IUGU_API_TEST_MODE};
        die "Missing IUGU_API_KEY"                      unless $ENV{IUGU_API_KEY};
        die "Missing IUGU_ACCOUNT_ID"                   unless $ENV{IUGU_ACCOUNT_ID};
        die "Missing IUGU_API_URL"                      unless $ENV{IUGU_API_URL};
		die "Missing VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID" unless $ENV{VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID};
		die "Missing VOTOLEGAL_LICENSE_IUGU_API_KEY"    unless $ENV{VOTOLEGAL_LICENSE_IUGU_API_KEY};

        $ENV{IUGU_MOCK} = 0;
    }
    else {

        $ENV{IUGU_MOCK}          = 1;
        $ENV{IUGU_API_TEST_MODE} = 1;
        $ENV{IUGU_API_KEY}       = 'Fooba';
        $ENV{IUGU_ACCOUNT_ID}    = 'Fooba';
        $ENV{IUGU_API_URL}       = 'http://foobar.com';

    }
}

has ua => ( is => "rw", isa => "Furl", builder => '_build_ua', lazy => 1, );

my $domain = URI->new( $ENV{IUGU_API_URL} );

sub _build_ua {
    my $self = shift;

    Furl->new(
        timeout => 30,
        # headers => [ Authorization => 'Basic ' . encode_base64( $ENV{IUGU_API_KEY} . ':' ) ]
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

    # Caso seja um pagamento de licença o account_id é diferente
    # E alguns dados obrigatórios também são diferentes
    my @required_opts;
    my $headers;
    if ( $opts{is_votolegal_payment} ) {
        $ENV{IUGU_ACCOUNT_ID} = $ENV{VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID};
        $ENV{IUGU_API_KEY}    = $ENV{VOTOLEGAL_LICENSE_IUGU_API_KEY};

		@required_opts = qw/
		  candidate_id
          due_date
		  is_boleto
		  payer
		  description
		  amount
		/;
    }
    else {
		@required_opts = qw/
		  due_date
		  donation_id
		  is_boleto
		  payer
		  description
		  amount
		/;
    }

    $headers = [ Authorization => 'Basic ' . encode_base64( $ENV{IUGU_API_KEY} . ':' ), 'Content-Type' => "application/json" ];

    defined $opts{$_} or croak "missing $_" for @required_opts;

    my ( $data, $body, $post_url );
    Log::Log4perl::NDC->remove();

    if ($opts{is_votolegal_payment}) {
		Log::Log4perl::NDC->push( "create_invoice votolegal_license candidate_id=" . $opts{candidate_id} . '  ' );
    } else {
        Log::Log4perl::NDC->push( "create_invoice donation_id=" . $opts{donation_id} . '  ' );
    }

    if ( !$ENV{IUGU_MOCK} ) {

        # checando se credit_card.two_step_transaction está habilitado
        if ( !$opts{is_boleto} ) {
            $logger->info("validating two_step_transaction...");
            Log::Log4perl::NDC->push( "account_id= $ENV{IUGU_ACCOUNT_ID}");
            my $res = $self->ua->get( $self->uri_for( 'accounts', $ENV{IUGU_ACCOUNT_ID} ), $headers );

            my $json = decode_json( $res->decoded_content )
              or croak 'create_invoice failed';

            die 'credit_card.two_step_transaction precisa estar habilitada na Iugu'
              unless $json->{configuration}
              && $json->{configuration}->{credit_card}->{two_step_transaction};
        }

    }

    my $invoice_email = $opts{is_votolegal_payment} ? $opts{candidate_id} . '@no-email.com' : $opts{donation_id} . '@no-email.com';
    $post_url = $self->uri_for('invoices');
    $data     = {
        email        => $invoice_email,
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
        my $res = $self->ua->post( $post_url, $headers, $body );
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
        $logger->info("POST $post_url\n$body");

        if ( $ENV{IUGU_MOCK} ) {

            # nothing to do here
        }
        else {
            my $res = $self->ua->post( $post_url, $headers, $body );

            $logger->info( "Iugu response: " . $res->decoded_content );

            my $json = decode_json( $res->decoded_content ) or croak "$post_url decode failed";
            croak "cannot create charge right now" if keys %{ $json->{errors} || {} };

            $invoice->{_charge_response_} = $json;
        }
    }

    Log::Log4perl::NDC->remove();
    return $invoice;
}

sub capture_invoice {
    my ( $self, %opts ) = @_;
    my $logger = get_logger;

    # Caso seja um pagamento de licença alguns dados obrigatórios também são diferentes
    my @required_opts;
    my $headers;

    if ( $opts{is_votolegal_payment} ) {
		$ENV{IUGU_API_KEY} = $ENV{VOTOLEGAL_LICENSE_IUGU_API_KEY};

		@required_opts = qw/
		    id
            candidate_id
        /;
    }
    else {
		@required_opts = qw/
		    id
            donation_id
        /;
    }

	$headers = [ Authorization => 'Basic ' . encode_base64( $ENV{IUGU_API_KEY} . ':' ), 'Content-Type' => "application/json" ];

    defined $opts{$_} or croak "missing $_" for @required_opts;

    my ( $data, $body, $post_url );
    Log::Log4perl::NDC->remove();

    if ( $opts{is_votolegal_payment} ) {
		Log::Log4perl::NDC->push( "capture_invoice votolegal license candidate_id=" . $opts{candidate_id} . '  ' );
    }
    else {
        Log::Log4perl::NDC->push( "capture_invoice donation_id=" . $opts{donation_id} . '  ' );
    }

    $post_url = $self->uri_for('invoices') . '/' . $opts{id} . '/capture';
    $data     = {};
    $body     = encode_json($data);
    $logger->info(" POST $post_url\n$body");

    # criando invoice
    my $invoice;
    if ( $ENV{IUGU_MOCK} ) {

        $invoice = $VotoLegal::Test::Further::iugu_invoice_response_capture;
    }
    else {
        my $res = $self->ua->post( $post_url, $headers, $body );
        $logger->info( "Iugu response: " . $res->decoded_content );

        $invoice = decode_json( $res->decoded_content )
          or croak 'capture_invoice parse json failed';
    }

    croak "capture error " . encode_json($invoice) unless $invoice->{status} eq 'paid';

    Log::Log4perl::NDC->remove();
    return $invoice;
}

sub get_invoice {
    my ( $self, %opts ) = @_;
    my $logger = get_logger;

    defined $opts{$_} or croak "missing $_" for qw/
      id
      donation_id
      /;

    my ( $data, $body, $post_url );
    Log::Log4perl::NDC->remove();

    Log::Log4perl::NDC->push( "get_invoice donation_id=" . $opts{donation_id} . '  ' );

    $post_url = $self->uri_for('invoices') . '/' . $opts{id};
    $logger->info(" GET $post_url");

    # criando invoice
    my $invoice;
    if ( $ENV{IUGU_MOCK} ) {
        $invoice = $VotoLegal::Test::Further::iugu_invoice_response;
    }
    else {
        my $res = $self->ua->get($post_url);
        $logger->info( "Iugu response: " . $res->decoded_content );

        croak 'get_invoice failed' unless $res->code == 200;

        $invoice = decode_json( $res->decoded_content )
          or croak 'get_invoice parse json failed';
    }
    Log::Log4perl::NDC->remove();

    return $invoice;
}
