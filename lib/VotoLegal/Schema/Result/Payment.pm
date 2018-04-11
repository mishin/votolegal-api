use utf8;
package VotoLegal::Schema::Result::Payment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::Payment

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

=head1 TABLE: C<payment>

=cut

__PACKAGE__->table("payment");

=head1 ACCESSORS

=head2 code

  data_type: 'text'
  is_nullable: 0

=head2 candidate_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 sender_hash

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 method

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "code",
  { data_type => "text", is_nullable => 0 },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sender_hash",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "method",
  { data_type => "text", is_nullable => 1 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-04-11 10:15:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0dy5N/ffFrOZUj0bjLLR2w


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use VotoLegal::Utils;
use VotoLegal::Payment::PagSeguro;

sub send_pagseguro_transaction {
    my ($self, $credit_card_token) = @_;

    my $pagseguro = VotoLegal::Payment::PagSeguro->new(
        merchant_id  => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_ID},
        merchant_key => $ENV{VOTOLEGAL_PAGSEGURO_MERCHANT_KEY},
        callback_url => $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL},
        sandbox      => is_test(),
        # logger       => $c->log,
    );

    my $candidate = $self->candidate;

    # Verifico se o candidato tem todos os dados necessários
    # para realizar o pagamento
    $candidate->validate_required_information_for_payment();

    my $sender       = $self->build_sender_object();
    my $item         = $self->build_item_object();
    my $shipping     = $self->build_shipping_object();
    my $creditCard   = $self->build_credit_card_object($credit_card_token);
    my $callback_url = $self->build_callback_url();
    my %payment_args = (
        method          => $self->method,
        sender          => $sender,
        items           => $item,
        shipping        => $shipping,
        reference       => $candidate->id,
        extraAmount     => "0.00",
        notificationURL => $callback_url,
        creditCard      => $creditCard ? $creditCard : ()
    );

    my $payment = $pagseguro->transaction(%payment_args);

    return $payment;
}

sub build_callback_url {
    my ($self) = @_;

    my $candidate    = $self->candidate;
    my $candidate_id = $self->candidate_id;

    my $callback_url = $ENV{VOTOLEGAL_PAGSEGURO_CALLBACK_URL};
    $callback_url   .= "/" unless $callback_url =~ m{\/$};
    $callback_url   .= "api/candidate/$candidate_id/payment/callback";

    return $callback_url;
}

sub build_sender_object {
    my ($self) = @_;

    my $candidate = $self->candidate;

    # No pré-cadastro colhemos apenas
    # o CPF, logo não é necessário
    # criar uma lógica que verifique
    # o document que o candidato possui
    # e seu respectivo type
    my $document = {
        document => {
            type  => 'CPF',
            value => $candidate->cpf
        }
    };

    return {
        hash      => $self->sender_hash,
        name      => $candidate->name,
        email     => (is_test() ? 'fvox@sandbox.pagseguro.com.br' : $candidate->user->email),
        documents => [ $document ]
    }
}

sub build_item_object {
    my ($self) = @_;

    my $item = [
        {
            item => {
                id          => 1,
                description => 'Pagamento Voto Legal',
                amount      => '495.00',
                quantity    => 1
            }
        }
    ];

    return $item;
}

sub build_shipping_object {
    my ($self) = @_;

    my $candidate = $self->candidate;

    return {
        address => $candidate->get_address_data()
    }
}

sub build_credit_card_object {
    my ($self, $credit_card_token) = @_;

    my $candidate = $self->candidate;

    my $credit_card = {
        token => $credit_card_token,
        holder => {
            name      => $candidate->name,
            documents => [
                document => {
                    type  => 'CPF',
                    value => $candidate->cpf
                }
            ],
            address  => $candidate->get_address_data()
        }
    };

    return $credit_card;
}

sub update_code {
    my ($self, $code) = @_;

    return $self->update( { code => $code } );
}

__PACKAGE__->meta->make_immutable;
1;
