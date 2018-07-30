package WebService::IuguForReal;
use strict;
use utf8;
use MooseX::Singleton;

use VotoLegal::Logger;
use Furl;
use URI;
use MIME::Base64 qw(encode_base64);
use JSON;
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
		die "Missing MAX_RETRY_WINDOW_IN_SECONDS"       unless $ENV{MAX_RETRY_WINDOW_IN_SECONDS};

        $ENV{IUGU_MOCK} = 0;
    }
    else {

        $ENV{IUGU_MOCK}                   = 1;
        $ENV{IUGU_API_TEST_MODE}          = 1;
        $ENV{IUGU_API_KEY}                = 'Fooba';
        $ENV{IUGU_ACCOUNT_ID}             = 'Fooba';
        $ENV{IUGU_API_URL}                = 'http://foobar.com';
        $ENV{MAX_RETRY_WINDOW_IN_SECONDS} = 2;

    }
}

has ua => ( is => "rw", isa => "Furl", builder => '_build_ua', lazy => 1, );

my $domain = URI->new( $ENV{IUGU_API_URL} );

sub _build_ua {
    my $self = shift;

    Furl->new( timeout => 60, );

}

sub uri_for {
    my $self = shift;
    my $uri  = $domain->clone;
    $uri->path_segments( 'v1', @_ );
    return $uri;
}

sub check_for_two_step {
    my ( $self, %opts ) = @_;
    my $logger = get_logger;

    my ( $acc, $pass );
    if ( $opts{is_votolegal_payment} ) {
        $acc  = $ENV{VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID};
        $pass = $ENV{VOTOLEGAL_LICENSE_IUGU_API_KEY};
    }
    else {
        $acc  = $ENV{IUGU_ACCOUNT_ID};
        $pass = $ENV{IUGU_API_KEY};
    }

    my $headers = [ Authorization => 'Basic ' . encode_base64( $pass . ':' ), 'Content-Type' => "application/json" ];

    $logger->info("validating two_step_transaction...");

    my $res = $self->ua->get( $self->uri_for( 'accounts', $acc ), $headers );

    my $json = decode_json( $res->decoded_content )
      or croak 'create_invoice failed';

    die 'credit_card.two_step_transaction precisa estar habilitada na Iugu'
      unless $json->{configuration}
      && $json->{configuration}->{credit_card}->{two_step_transaction};
    return 1;

}

sub create_invoice {
    my ( $self, %opts ) = @_;
    my $logger = get_logger;

    # Caso seja um pagamento de licença o account_id é diferente
    # E alguns dados obrigatórios também são diferentes
    my @required_opts;
    my $headers;
    my ( $acc, $pass );
    if ( $opts{is_votolegal_payment} ) {
        $acc  = $ENV{VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID};
        $pass = $ENV{VOTOLEGAL_LICENSE_IUGU_API_KEY};

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

        $acc  = $ENV{IUGU_ACCOUNT_ID};
        $pass = $ENV{IUGU_API_KEY};

        @required_opts = qw/
          due_date
          donation_id
          is_boleto
          payer
          description
          amount
          /;
    }

    $headers = [ Authorization => 'Basic ' . encode_base64( $pass . ':' ), 'Content-Type' => "application/json" ];

    defined $opts{$_} or croak "missing $_" for @required_opts;

    my ( $data, $body, $post_url );
    Log::Log4perl::NDC->remove();

    if ( $opts{is_votolegal_payment} ) {
        Log::Log4perl::NDC->push( "create_invoice votolegal_license candidate_id=" . $opts{candidate_id} . '  ' );
    }
    else {
        Log::Log4perl::NDC->push( "create_invoice donation_id=" . $opts{donation_id} . '  ' );
    }


    my $invoice_email =
      $opts{is_votolegal_payment} ? $opts{candidate_id} . '@no-email.com' : $opts{donation_id} . '@no-email.com';
    $post_url = $self->uri_for('charge');
    $data     = {
        email                   => $invoice_email,
        payer                   => $opts{payer},
        due_date                => $opts{due_date},
        order_id                => $opts{donation_id},
        restrict_payment_method => \1,
        items => [
            {
                description => $opts{description},
                quantity    => 1,
                price_cents => $opts{amount},
            }
        ],

        ( $opts{is_boleto} ? ( method => 'bank_slip' ) : ( token => $opts{credit_card_token} ) )
    };
    $body = encode_json($data);
    $logger->info("creating_direct_charge: POST $post_url\n$body");

    # criando invoice
    my $invoice;
    if ( $ENV{IUGU_MOCK} ) {

        $invoice = $VotoLegal::Test::Further::iugu_invoice_response;
    }
    else {
        my $start = time();
        my $now   = time();

        while (1) {
            $now = time();

            if ( $now - $start <= $ENV{MAX_RETRY_WINDOW_IN_SECONDS} ) {
				my $res = $self->ua->post( $post_url, $headers, $body );
				$logger->info( 'Iugu response: ' . $res->decoded_content );

                eval { $invoice = decode_json( $res->decoded_content ) };

                if ($@) {
                    $logger->info( 'Could not decode JSON' );
                }

                # Caso a Iugu retorne que a invoice com o order_id informado
                # ja exista, devo buscar no get_invoice
                my $donation_id = $opts{donation_id};
                if ( $invoice->{errors} && $invoice->{errors} =~ m/$donation_id/ ) {
                    my %duplicate_invoice_opts = (
                        donation_id           => "$donation_id",
                        get_duplicate_invoice => 1
                    );
                    $invoice = $self->get_invoice(%duplicate_invoice_opts);
                }
                else {
					die "Iugu response error: " . $res->decoded_content
					  if $invoice->{errors} && keys %{ $invoice->{errors} };
                }

                last if $res->is_success || $invoice->{totalItems} > 0;
                sleep 1;
            }
            else {
                croak 'max gateway retry window reached';
            }
        }
    }

    croak 'cannot create charge right now (invoice id not found)' unless $invoice->{invoice_id};

    $invoice->{id} = $invoice->{invoice_id};

    Log::Log4perl::NDC->remove();

    return $invoice;
}

sub capture_invoice {
    my ( $self, %opts ) = @_;
    my $logger = get_logger;

    # Caso seja um pagamento de licença alguns dados obrigatórios também são diferentes
    my @required_opts;
    my $headers;

    my ( $acc, $pass );

    if ( $opts{is_votolegal_payment} ) {
        $acc  = $ENV{VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID};
        $pass = $ENV{VOTOLEGAL_LICENSE_IUGU_API_KEY};

        @required_opts = qw/
          id
          candidate_id
          /;
    }
    else {

        $acc  = $ENV{IUGU_ACCOUNT_ID};
        $pass = $ENV{IUGU_API_KEY};

        @required_opts = qw/
          id
          donation_id
          /;
    }

    $headers = [ Authorization => 'Basic ' . encode_base64( $pass . ':' ), 'Content-Type' => "application/json" ];

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

	my @required_opts;
	$logger->info("$_ :" . $opts{$_} ) for (keys %opts);

    if ( $opts{get_duplicate_invoice} ) {
        $logger->info('Going to search for duplicate invoice' );
        @required_opts = qw/
            donation_id
        /;
    }
    else {
		@required_opts = qw/
		  id
		  donation_id
		/;
    }

    defined $opts{$_} or croak "missing $_" for @required_opts;

    my ( $acc, $pass );

    if ( $opts{is_votolegal_payment} ) {
        $acc  = $ENV{VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID};
        $pass = $ENV{VOTOLEGAL_LICENSE_IUGU_API_KEY};

    }
    else {
        $acc  = $ENV{IUGU_ACCOUNT_ID};
        $pass = $ENV{IUGU_API_KEY};
    }

    my $headers = [ Authorization => 'Basic ' . encode_base64( $pass . ':' ), 'Content-Type' => "application/json" ];

    my ( $data, $body, $post_url );
    Log::Log4perl::NDC->remove();

    Log::Log4perl::NDC->push( "get_invoice donation_id=" . $opts{donation_id} . '  ' );

    if ( $opts{get_duplicate_invoice} ) {
		$post_url = $self->uri_for('invoices') . '?query=' . $opts{donation_id};
    }
    else {
        $post_url = $self->uri_for('invoices') . '/' . $opts{id};
    }

    $logger->info(" GET $post_url");

    # criando invoice
    my $invoice;
    if ( $ENV{IUGU_MOCK} ) {
        $invoice = $VotoLegal::Test::Further::iugu_invoice_response;
    }
    else {
        my $tries = 5;
        while (1) {
            eval {
                my $res = $self->ua->get( $post_url, $headers );
                $logger->info( "Iugu response: " . $res->decoded_content );

                croak 'get_invoice failed' unless $res->code == 200;

                $invoice = decode_json( $res->decoded_content )
                  or croak 'get_invoice parse json failed';
            };
            if ($@) {
                $tries--;
                if ( $tries == 0 ) {
                    die $@;
                }
                $logger->info("trying again in 1 sec....");
                sleep 1;
            }
            else {
                last;
            }
        }
    }
    Log::Log4perl::NDC->remove();

    return $invoice;
}
