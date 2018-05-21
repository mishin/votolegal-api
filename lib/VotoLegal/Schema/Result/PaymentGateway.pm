#<<<
use utf8;
package VotoLegal::Schema::Result::PaymentGateway;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("payment_gateway");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "payment_gateway_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "class",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "candidates",
  "VotoLegal::Schema::Result::Candidate",
  { "foreign.payment_gateway_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "donations",
  "VotoLegal::Schema::Result::Donation",
  { "foreign.payment_gateway_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "votolegal_donations",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { "foreign.payment_gateway_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uVR/4US916MV4qxA5kLWlg

use Carp;
use WebService::IuguForReal;
with 'VotoLegal::Schema::Role::ResultsetFind';

sub create_invoice {
    my ( $self, %opts ) = @_;

    croak 'class not supported' unless $self->class eq 'IUGU';

    defined $opts{$_} or croak "missing $_" for qw/
      candidate_id
      is_boleto
      donation_id
      amount
      payer
      description
      /;

    croak 'missing credit_card_token' if !$opts{credit_card_token} && !$opts{is_boleto};
    croak 'missing payer' unless ref $opts{payer} eq 'HASH';
    croak 'missing payer.cpf_cnpj' if $opts{payer}{cpf_cnpj} !~ /^[0-9]+$/;

    if ( $opts{is_boleto} ) {
        defined $opts{payer}{address}{$_}
          or croak "missing payer.address.$_"
          for qw/city district state street zip_code/;
    }

    my $candidate = $self->resultset('Candidate')->search(
        {
            id => $opts{candidate_id}

        },
        {
            '+columns' => [
                {
                    due_date => \"timezone('America/Sao_Paulo', now())::date + '5 days'::interval"
                }
            ]
        }
    )->next;

    my $due_date = $candidate->get_column('due_date');

    my $ws = WebService::IuguForReal->instance;

    my $invoice = $ws->create_invoice(
        %opts,
        due_date    => $due_date,
        description => $opts{description},
    );

    return {
        payment_info => $invoice,
        gateway_tid  => $invoice->{id},
    };

}

sub data_for_credit_card_generation {
    my ( $self, %opts ) = @_;

    croak 'class not supported' unless $self->class eq 'IUGU';

    return {
        payment_info => {
            is_testing => $ENV{IUGU_API_IS_TEST} ? 1 : 0,
            account_id => $ENV{IUGU_ACCOUNT_ID},
        },

    };

}

sub get_invoice {
    my ( $self, %opts ) = @_;

    defined $opts{$_} or croak "missing $_" for qw/
      donation_id
      id
      /;
    croak 'class not supported' unless $self->class eq 'IUGU';

    my $ws = WebService::IuguForReal->instance;

    my $invoice = $ws->get_invoice(%opts);

    return { payment_info => $invoice, };
}

sub capture_invoice {
    my ( $self, %opts ) = @_;

    defined $opts{$_} or croak "missing $_" for qw/
      donation_id
      id
      /;
    croak 'class not supported' unless $self->class eq 'IUGU';

    my $ws = WebService::IuguForReal->instance;

    my $invoice = $ws->capture_invoice(%opts);

    return { payment_info => $invoice, };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
