use utf8;
package VotoLegal::Schema::Result::VotolegalDonation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::VotolegalDonation

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<votolegal_donation>

=cut

__PACKAGE__->table("votolegal_donation");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v1()
  is_nullable: 0
  size: 16

=head2 candidate_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 state

  data_type: 'text'
  default_value: 'created'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 captured_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 refunded_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 compensated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 transferred_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 is_boleto

  data_type: 'boolean'
  is_nullable: 0

=head2 is_pre_campaign

  data_type: 'boolean'
  is_nullable: 0

=head2 payment_info

  data_type: 'json'
  is_nullable: 1

=head2 gateway_tid

  data_type: 'text'
  is_nullable: 1

=head2 gateway_data

  data_type: 'json'
  is_nullable: 1

=head2 callback_id

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 payment_gateway_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 device_authorization_token_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 stash

  data_type: 'json'
  is_nullable: 1

=head2 decred_capture_registered_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 decred_capture_txid

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 votolegal_fp

  data_type: 'bigint'
  is_nullable: 1

=head2 decred_merkle_root

  data_type: 'text'
  is_nullable: 1

=head2 decred_merkle_registered_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 decred_data_raw

  data_type: 'text'
  is_nullable: 1

=head2 decred_data_digest

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v1()",
    is_nullable => 0,
    size => 16,
  },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "state",
  {
    data_type     => "text",
    default_value => "created",
    is_nullable   => 0,
    original      => { data_type => "varchar" },
  },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "captured_at",
  { data_type => "timestamp", is_nullable => 1 },
  "refunded_at",
  { data_type => "timestamp", is_nullable => 1 },
  "compensated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "transferred_at",
  { data_type => "timestamp", is_nullable => 1 },
  "is_boleto",
  { data_type => "boolean", is_nullable => 0 },
  "is_pre_campaign",
  { data_type => "boolean", is_nullable => 0 },
  "payment_info",
  { data_type => "json", is_nullable => 1 },
  "gateway_tid",
  { data_type => "text", is_nullable => 1 },
  "gateway_data",
  { data_type => "json", is_nullable => 1 },
  "callback_id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "payment_gateway_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "device_authorization_token_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "stash",
  { data_type => "json", is_nullable => 1 },
  "decred_capture_registered_at",
  { data_type => "timestamp", is_nullable => 1 },
  "decred_capture_txid",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "votolegal_fp",
  { data_type => "bigint", is_nullable => 1 },
  "decred_merkle_root",
  { data_type => "text", is_nullable => 1 },
  "decred_merkle_registered_at",
  { data_type => "timestamp", is_nullable => 1 },
  "decred_data_raw",
  { data_type => "text", is_nullable => 1 },
  "decred_data_digest",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 candidate

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 certiface_tokens

Type: has_many

Related object: L<VotoLegal::Schema::Result::CertifaceToken>

=cut

__PACKAGE__->has_many(
  "certiface_tokens",
  "VotoLegal::Schema::Result::CertifaceToken",
  { "foreign.votolegal_donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 device_authorization_token

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DeviceAuthorizationToken>

=cut

__PACKAGE__->belongs_to(
  "device_authorization_token",
  "VotoLegal::Schema::Result::DeviceAuthorizationToken",
  { id => "device_authorization_token_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 payment_gateway

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::PaymentGateway>

=cut

__PACKAGE__->belongs_to(
  "payment_gateway",
  "VotoLegal::Schema::Result::PaymentGateway",
  { id => "payment_gateway_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 votolegal_donation_immutable

Type: might_have

Related object: L<VotoLegal::Schema::Result::VotolegalDonationImmutable>

=cut

__PACKAGE__->might_have(
  "votolegal_donation_immutable",
  "VotoLegal::Schema::Result::VotolegalDonationImmutable",
  { "foreign.votolegal_donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-20 20:49:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XXmtxlxWVlK0eOFmVyPCHg

use Carp;
use JSON::XS;
use JSON qw/to_json from_json/;
use Digest::SHA qw/ sha256_hex /;
use WebService::Certiface;

sub resultset { shift->result_source->resultset }

sub as_row {
    my ($self) = @_;

    my $donation = $self->resultset('VotolegalDonation')->search(
        {
            id => $self->id
        },
        {
            prefetch => 'votolegal_donation_immutable'
        }
    )->next;

    my $immu = $donation->votolegal_donation_immutable;
    my $ret  = {
        ( map { $_ => $donation->$_ } qw/id/ ),
        donor => {
            name => $immu->donor_name,
            cpf  => $immu->get_column('donor_cpf'),
        },
        captured_at => $donation->captured_at ? $donation->captured_at->datetime : undef,
        amount => $immu->amount,
    };

    return $ret;

}

sub as_row_for_email_variable {
    my ($self) = @_;

    my $donation = $self->resultset('VotolegalDonation')->search(
        {
            'me.id' => $self->id
        },
        {
            join         => [ 'votolegal_donation_immutable', 'candidate' ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',

            columns => [

                'me.id',
                'me.is_pre_campaign',
                'candidate.campaign_donation_type',
                'candidate.cpf',
                'candidate.cnpj',
                { donor_name           => 'votolegal_donation_immutable.donor_name' },
                { donor_email          => 'votolegal_donation_immutable.donor_email' },
                { amount_human         => \"replace((votolegal_donation_immutable.amount/100)::numeric(7, 2)::text, '.', ',')" },
                { payment_method_human => \"case when me.is_boleto then 'Boleto' else 'Cartão de crédito' end" },
                {
                    captured_at_human => \
                      "to_char( timezone('America/Sao_Paulo', timezone('UTC', captured_at)) , 'DD/MM/YYYY hh::mm:ss')"
                },
                {
                    refunded_at_human => \
                      "to_char( timezone('America/Sao_Paulo', timezone('UTC', refunded_at)) , 'DD/MM/YYYY hh::mm:ss')"
                },
              ]

        }
    )->next;


    return $donation;
}

sub obtain_lock {
    my ($self) = @_;

    my ($lock_myself) =
      $self->result_source->schema->resultset('VotolegalDonation')
      ->search( { 'me.id' => $self->id }, { for => \'UPDATE', columns => ['id'] } )->next;

    # pre-fetch depois do lock, para nao dar erro
    $lock_myself = $self->result_source->schema->resultset('VotolegalDonation')->search(
        { 'me.id' => $self->id },
        {
            prefetch => [ 'candidate', 'votolegal_donation_immutable' ]
        }
    )->next;

    return $lock_myself;
}

sub stash_parsed {
    my ($self) = @_;

    return $self->stash ? from_json( $self->stash ) : {};
}

sub set_new_state {
    my ( $self, $new_state, $new_stash ) = @_;
    $self->update(
        {
            state => $new_state,
            stash => $new_stash ? to_json($new_stash) : undef,
        }
    );

    return 1;
}

sub payment_info_parsed {
    my ($self) = @_;
    return $self->payment_info ? from_json( $self->payment_info ) : {};
}

sub _create_invoice {
    my ($self) = @_;

    my $stash = $self->stash_parsed;

    my $gateway = $self->payment_gateway;
    my $immu    = $self->votolegal_donation_immutable;

    my $invoice = $gateway->create_invoice(
        credit_card_token => $stash->{credit_card_token},
        is_boleto         => $self->is_boleto,

        description => $self->generate_boleto_description(),

        amount       => $immu->amount,
        candidate_id => $self->candidate_id,

        donation_id => $self->id(),

        payer => {
            cpf_cnpj => $immu->get_column('donor_cpf'),
            name     => $immu->donor_name,
            address  => {
                state    => $immu->billing_address_state,
                city     => $immu->billing_address_city,
                district => $immu->billing_address_district,
                zip_code => $immu->billing_address_zipcode,
                street   => $immu->billing_address_street,
                number   => $immu->billing_address_house_number,
            }
          }

    );

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            gateway_tid  => $invoice->{gateway_tid},
            payment_info => to_json($payment_info),
        }
    );

}

sub _generate_payment_credit_card {

    my ($self) = @_;

    my $gateway = $self->payment_gateway;

    my $invoice = $gateway->data_for_credit_card_generation();

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            payment_info => to_json($payment_info),
        }
    );
}

sub capture_cc {
    my ($self) = @_;

    my $gateway = $self->payment_gateway;

    my $invoice = $gateway->capture_invoice( donation_id => $self->id, id => $self->gateway_tid );

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            payment_info => to_json($payment_info),
            captured_at  => $payment_info->{paid_at},
        }
    );
}

sub sync_gateway_status {
    my ($self) = @_;
    my $gateway = $self->payment_gateway;

    my $invoice = $gateway->get_invoice( donation_id => $self->id, id => $self->gateway_tid );

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            payment_info => to_json($payment_info),
        }
    );

    return $self;
}

sub set_boleto_paid {
    my ($self) = @_;

    die 'cannot set_boleto_paid' unless $self->is_boleto;
    die 'cannot set_boleto_paid' unless !$self->captured_at;

    my $payment_info = $self->payment_info_parsed;
    $self->update(
        {
            captured_at => $payment_info->{paid_at},
        }
    );
}

sub generate_certiface_link {
    my ($self) = @_;

    die 'cannot generate_certiface_link after boleto_authentication' unless $self->state eq 'boleto_authentication';

    my $payment_info = $self->payment_info_parsed;

    my $ws = WebService::Certiface->instance;

    my $immu = $self->votolegal_donation_immutable;

    my $certiface = $ws->generate_token(
        {
            cpf        => $immu->donor_cpf,
            telefone   => $immu->donor_phone,
            nome       => $immu->donor_name,
            nascimento => $immu->donor_birthdate->dmy('/'),
        }
    );

    $payment_info->{certiface_id} = $certiface->{uuid};

    $self->certiface_tokens->create(
        {
            id               => $certiface->{uuid},
            verification_url => $certiface->{url},
        }
    );

    $self->update(
        {
            payment_info => to_json($payment_info),
        }
    );
}

sub current_certiface {
    my ($self) = @_;

    my $payment_info = $self->payment_info_parsed;

    $payment_info->{certiface_id} or croak 'no certiface_id found';

    return $self->certiface_tokens->search( { id => $payment_info->{certiface_id} } )->next;

}

sub generate_boleto_description {
    my ($self) = @_;

    my $candidate = $self->candidate;
    my $type_tx   = $self->is_pre_campaign ? 'pré-campanha' : 'campanha';
    my $name_tx   = $self->is_pre_campaign ? 'pré-candidato' : 'candidato';

    my $desc;

    if ( $candidate->campaign_donation_type eq 'party' ) {

        $desc = "Doação para o partido " . $candidate->popular_name;
    }
    else {
        $desc = "Doação para $type_tx " . $candidate->popular_name . ' (' . $candidate->name . ') ';

        if ( $self->is_pre_campaign ) {

            $desc .= "CPF do $name_tx para declaração no IR " . $candidate->cpf_formated;
        }
        else {

            $desc .= "CNPJ do $name_tx para declaração no IR " . $candidate->cnpj_formated;
        }
    }

    return $desc;

}

sub upsert_decred_data {
    my $self = shift;

    my $immutable = $self->votolegal_donation_immutable;
    my $candidate = $self->candidate;

    my $data_raw    = $self->get_column('decred_data_raw');
    my $data_digest = $self->get_column('decred_data_digest');
    my $is_boleto   = $self->get_column('is_boleto');

    if (!defined($data_raw) && !defined($data_digest)) {
        $data_raw = join(
            "\n",
            "@@ DOADOR\n",
            $self->id,
            $immutable->get_column('donor_name'),
            $immutable->get_column('donor_cpf'),
            $immutable->get_column('amount'),
            $self->created_at->datetime(),
            $is_boleto ? 'Boleto' : 'Cartão de crédito',
            $immutable->get_column('git_hash'),
            "\n@@ CANDIDATO\n",
            $candidate->get_column('name'),
            $candidate->party->get_column('name'),
            $candidate->cpf_formated(),
            $candidate->cnpj_formated() || '00.000.000/0000-00',
        );

        $data_digest = sha256_hex($data_raw);

        $self->update(
            {
                decred_data_raw    => $data_raw,
                decred_data_digest => $data_digest,
            }
        );
    }

    return $self->discard_changes;
}

__PACKAGE__->meta->make_immutable;
1;
