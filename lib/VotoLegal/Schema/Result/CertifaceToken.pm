#<<<
use utf8;
package VotoLegal::Schema::Result::CertifaceToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");
__PACKAGE__->table("certiface_token");
__PACKAGE__->add_columns(
  "id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "verification_url",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "votolegal_donation_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "validated",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "fail_reasons",
  { data_type => "json", is_nullable => 1 },
  "response_updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "response",
  { data_type => "json", is_nullable => 1 },
  "certiface_return_url_id",
  {
    data_type      => "integer",
    default_value  => 1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "certiface_return_count",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "certiface_return_url",
  "VotoLegal::Schema::Result::CertifaceReturnUrl",
  { id => "certiface_return_url_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "votolegal_donation",
  "VotoLegal::Schema::Result::VotolegalDonation",
  { id => "votolegal_donation_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-21 09:57:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RsofEtczLvOuxH5O0ERO8Q

use WebService::Certiface;
use JSON qw/to_json/;
use DateTime::Format::Pg;

sub process_response_and_validate {
    my ($self) = @_;

    return 1 if $self->response;

    my $ws = WebService::Certiface->instance;

    my $response = $ws->get_token_information( $self->id );
    return 0 unless $response;

    my $is_any_valid = grep { $_->{valid} } @{ $response->{resultados} || [] };
    my @fail_reasons = map { $_->{cause} } grep { $_->{valid} == 0 } @{ $response->{resultados} || [] };

    # Caso o o Face Captcha tenha falhado 3 vezes
    # e todos os erros tenham sido *apenas* prova de vida
    # a geração do boleto prossegue normalmente.
    my $error_string = join '', @fail_reasons;
    $is_any_valid = 1 if $error_string eq 'PROVA DE VIDAPROVA DE VIDAPROVA DE VIDA';

    $self->update(
        {
            validated           => $is_any_valid,
            fail_reasons        => to_json( \@fail_reasons ),
            response            => to_json($response),
            response_updated_at => \'now()',
        }
    );

    # nao foi verificado, se tiver expirado, vamos gerar um novo token
    # e o token nao foi utilizado ja as 3 vezes
    if ( !$is_any_valid && scalar @fail_reasons < 3 ) {

        my $x = $self->result_source->schema->resultset('CertifaceToken')->search(
            { id => $self->id },
            {
                'columns' => [
                    {
                        expirado => \[
                            " (now() - (? || ' America/Sao_Paulo')::timestamp with time zone) >= '0'",
                            $response->{dataExpiracao}
                        ]
                    },
                ],
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            }
        )->next;

        return $x->{expirado};
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;
