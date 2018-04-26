package VotoLegal::Payment::Iugu;
use common::sense;
use Moose;

use Furl;
use URI;
use MIME::Base64 qw(encode_base64);
use JSON::MaybeXS qw(encode_json decode_json);
use Carp 'croak';

has ua => (is => "rw", isa => "Furl", builder => '_build_ua', lazy => 1,);
has 'logger' => (is => 'rw', required => 1, isa => 'Any',);
has sandbox    => (is => 'ro', default  => sub {1});

my $domain = URI->new('https://api.iugu.com');

sub _build_ua {
  my $self = shift;
  Furl->new(
    timeout => 90,
    headers =>
      [Authorization => 'Basic ' . encode_base64($self->api_token . ':')]
  );

}

sub uri_for {
  my $self = shift;
  my $uri  = $domain->clone;
  $uri->path_segments('v1', @_);
  return $uri;
}

# Por enquanto não está definido como será o split
# se cada usuário terá uma subconta ou se serão apenas
# nossas subcontas

sub create_account {
  my ($self, %opts) = @_;
  my $data = {
    'email' => $opts{customer}->id . '@no-email.com',
    'name'  => $opts{customer}->name,

#    'cpf_cnpj'       => $opts{customer}->legal_document,
    custom_variables => [{name => 'local_id', value => $opts{customer}->id}]
  };

  my $body = encode_json($data);

  my $res = $self->ua->post($self->uri_for('customers'),
    ['Content-Type' => "application/json",], $body);

  $self->logger->debug("Iugu response: " . $res->decoded_content);

  my $json = decode_json($res->decoded_content)
    or croak 'create_account failed';

  $opts{update_status}->(
    last_request            => $body,
    last_response           => $res->decoded_content,
    transaction_description => 'create_account'
  );


  if (exists $json->{id}) {

    return Flotum::Schema::Definite::MerchantCustomerAccount->new(
      remote_identifier => $json->{id},
      metadata          => $json
    );

  }
  else {

    croak 'create_account failed';

  }

}

sub tokenize_credit_card {
  my ($self, %opts) = @_;

  my $account = $opts{account};
  my $cc      = $opts{credit_card_data}{credit_card};

  my ($first_name, $last_name) = split ' ', $cc->{name_on_card}, 2;
  my ($year, $month) = $cc->{validity} =~ /(\d{4})(\d{2})/o;
  my $data = {
    account_id => $ENV{IUGU_ACCOUNT_ID},
    method     => 'credit_card',
    test       => \($self->sandbox),
    data       => {
      number             => $opts{credit_card_data}{secret}{number},
      verification_value => $opts{credit_card_data}{secret}{csc},
      first_name         => $first_name,
      last_name          => $last_name,
      month              => $month,
      year               => $year,
    }
  };
  my $body = encode_json($data);

  # criando token

  my $res = $self->ua->post($self->uri_for('payment_token'),
    ['Content-Type' => "application/json",], $body);

  $self->logger->debug("Iugu response: " . $res->decoded_content);


  my $json = decode_json($res->decoded_content)
    or croak 'tokenize_credit_card failed';


  if (exists $json->{id}) {

    # cria meio de pagamento do customer usando o token criado anteriormente
    my $token  = $json->{id};
    my $number = $opts{credit_card_data}{secret}{number};
    my $mask   = '*' x ((length $number) - 7);
    $mask = substr($number, 0, 4) . $mask . substr($number, -3, 3);

    my $data = {description => $mask, token => $json->{id},};
    my $body = encode_json($data);
    $self->logger->debug("Iugu: Attaching token to customer: " . $body);
    my $res = $self->ua->post(
      $self->uri_for(
        'customers', $account->remote_identifier,
        'payment_methods'
      ),
      ['Content-Type' => "application/json",],
      $body
    );
    $self->logger->debug("Iugu response: " . $res->decoded_content);
    my $json = decode_json($res->decoded_content)
      or croak 'tokenize_credit_card failed';

    croak 'tokenize_credit_card failed' unless $json->{id};

    $opts{update_status}->(
      last_request            => $body,
      last_response           => $res->decoded_content,
      transaction_description => 'tokenize_credit_card'
    );
    return $json->{id};
  }
  else {
    croak 'tokenize_credit_card failed';
  }
}

sub do_authorization {
  my ($self, %opts) = @_;

  croak 'missing token' unless $opts{token};
  my $token = $opts{token};

  # checando se credit_card.two_step_transaction está habilitado
  {
    my $res = $self->ua->get(
      $self->uri_for('accounts', $self->account_id),
      ['Content-Type' => "application/json",]
    );

    my $json = decode_json($res->decoded_content)
      or croak 'do_authorization failed';

    die 'credit_card.two_step_transaction precisa estar habilitada na Iugu'
      unless $json->{configuration}
      && $json->{configuration}->{credit_card}->{two_step_transaction};

  }

  my $data = {
    'email'      => $opts{customer}->id . '@no-email.com',
    due_date     => DateTime->now->date,
    payable_with => 'credit_card',
    items        => [
      {
        description => $opts{soft_descriptor} || 'Pagamento',
        quantity    => 1,
        price_cents => $opts{amount},
      }
    ],
  };
  my $body = encode_json($data);

  # criando invoice
  my $res = $self->ua->post($self->uri_for('invoices'),
    ['Content-Type' => "application/json",], $body);

  $self->logger->debug("Iugu response: " . $res->decoded_content);


  my $json = decode_json($res->decoded_content)
    or croak 'do_authorization failed';

  die 'resposta nao esperada' unless $json->{id};

  $opts{update_status}->(
    last_request            => $body,
    last_response           => $res->decoded_content,
    transaction_description => 'do_authorization'
  );


  my $invoice_id = $json->{id};

  #pagamento com o token

  {
    my $data = {
      customer_payment_method_id => $token,
      restrict_payment_method    => \1,
      invoice_id                 => $invoice_id,
    };

    my $body = encode_json($data);
    $opts{update_status}
      ->(last_request => $body, transaction_description => 'do_capture');


    my $res = $self->ua->post($self->uri_for('charge'),
      ['Content-Type' => "application/json",], $body);

    my $json = decode_json($res->decoded_content) or croak 'do_capture failed';

    die 'resposta nao esperada' unless $json->{success};

  }

  $opts{update_status}->(
    last_request            => $body,
    last_response           => $res->decoded_content,
    transaction_description => 'do_authorization'
  );


  return {captured => 0, authorized => 1, transaction_id => $invoice_id};
}

sub cancel_charge {
  my ($self, %opts) = @_;

  croak 'missing transaction_id' unless $opts{transaction_id};

  my $res
    = $self->ua->post(
    $self->uri_for('invoices', $opts{transaction_id}, 'cancel'),
    ['Content-Type' => "application/json",]);

  $self->logger->debug("Iugu response: " . $res->decoded_content);

  $opts{update_status}->(
    last_request            => '',
    last_response           => $res->decoded_content,
    transaction_description => 'cancel_charge'
  );

  my $json = decode_json($res->decoded_content) or croak 'cancel_charge failed';

  die 'resposta nao esperada'
    unless $json->{id} && ($json->{status} eq 'canceled');

  return 1;

}

sub do_capture {
  my ($self, %opts) = @_;

  croak 'missing transaction_id' unless $opts{transaction_id};

  my $res
    = $self->ua->post(
    $self->uri_for('invoices', $opts{transaction_id}, 'capture'),
    ['Content-Type' => "application/json",]);

  $self->logger->debug("Iugu response: " . $res->decoded_content);

  $opts{update_status}->(
    last_request            => '',
    last_response           => $res->decoded_content,
    transaction_description => 'do_capture'
  );

  my $json = decode_json($res->decoded_content) or croak 'do_capture failed';

  die 'resposta nao esperada'
    unless $json->{status} && ($json->{status} eq 'paid');

  return {captured => 1, authorized => 0, transaction_id => $json->{id}};
}


__PACKAGE__->meta->make_immutable;

1;
