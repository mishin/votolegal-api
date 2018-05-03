use utf8;
package VotoLegal::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_id_seq'

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_id_seq",
  },
  "password",
  { data_type => "text", is_nullable => 1 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("user_email_key", ["email"]);

=head1 RELATIONS

=head2 candidates

Type: has_many

Related object: L<VotoLegal::Schema::Result::Candidate>

=cut

__PACKAGE__->has_many(
  "candidates",
  "VotoLegal::Schema::Result::Candidate",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contract_signatures

Type: has_many

Related object: L<VotoLegal::Schema::Result::ContractSignature>

=cut

__PACKAGE__->has_many(
  "contract_signatures",
  "VotoLegal::Schema::Result::ContractSignature",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_forgot_passwords

Type: has_many

Related object: L<VotoLegal::Schema::Result::UserForgotPassword>

=cut

__PACKAGE__->has_many(
  "user_forgot_passwords",
  "VotoLegal::Schema::Result::UserForgotPassword",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<VotoLegal::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "VotoLegal::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_sessions

Type: has_many

Related object: L<VotoLegal::Schema::Result::UserSession>

=cut

__PACKAGE__->has_many(
  "user_sessions",
  "VotoLegal::Schema::Result::UserSession",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-04-09 15:34:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Sy42cirwMDs+Z5Vfjq4RQw

use Crypt::PRNG qw(random_string);
use Data::Section::Simple qw(get_data_section);

__PACKAGE__->remove_column('password');
__PACKAGE__->add_column(
    password => {
        data_type        => "text",
        passphrase       => 'crypt',
        passphrase_class => 'BlowfishCrypt',
        passphrase_args  => {
            cost        => 8,
            salt_random => 1,
        },
        passphrase_check_method => 'check_password',
        is_nullable             => 0
    },
);

sub new_session {
    my ($self, %args) = @_;

    my $schema = $self->result_source->schema;

    my $session = $schema->resultset('UserSession')->search({
        user_id      => $self->id,
        valid_for_ip => $args{ip},
    })->first;

    if (!defined($session)) {
        $session = $self->user_sessions->create({
            valid_for_ip => $args{ip},
            api_key      => random_string(128),
        });
    }

    my $candidate = $self->candidates->next;

    return {
        user_id        => $self->id,
        candidate_id   => $candidate ? $candidate->id   : undef,
        candidate_name => $candidate ? $candidate->name : undef,
        roles          => [ map { $_->name } $self->roles ],
        api_key        => $session->api_key,
    };
}

sub send_email_forgot_password {
    my ($self, $token) = @_;

    # Admin não possui relação 'Candidato', logo, não possui 'name'. Então, quando não houver Candidate, passo o
    # endereço de email para o template para que fique "Olá admin@votolegal.org...".
    my $name;
    if (my $candidate = $self->candidates->next) {
        $name = $candidate->name;
    }
    else {
        $name = $self->email;
    }

    my $email = VotoLegal::Mailer::Template->new(
        to       => $self->email,
        from     => 'no-reply@votolegal.org.br',
        subject  => "VotoLegal - Recuperação de senha",
        template => get_data_section('forgot_password.tt'),
        vars     => {
            name  => $name,
            token => $token,
            url   => $ENV{VOTOLEGAL_FRONT_URL}
        },
    )->build_email();

    return $self->result_source->schema->resultset('EmailQueue')->create({
        body => $email->as_string,
    });
}

sub has_signed_contract {
    my ($self) = @_;

    return $self->contract_signatures->count;
}

__PACKAGE__->meta->make_immutable;

1;

__DATA__

@@ forgot_password.tt

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>

<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td colspan="2"><a href="https://www.votolegal.org.br/"><img src="https://www.votolegal.org.br/email/header.jpg" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
  <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
    <p><span><b>Olá [% name %], </b><br>
      <br></span></p>
    <p> <strong> </strong>Recebemos a sua solicitação para uma nova senha de acesso ao Voto Legal.
É muito simples, clique no botão abaixo para trocar sua senha.</p>
  </td>
</tr>
<tr>
<td height="30"></td>
</tr>
<tr>
<td align="center" bgcolor="#ffffff" valign="top" style="padding-top:20px">
<table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:separate; border-radius:7px; margin:0">
<tbody>
<tr>
<td align="center" valign="middle"><a href="[% url %]conta/trocar-senha/?token=[% token %]" target="_blank" class="x_btn" style="background:#4ab957; border-radius:8px; color:#ffffff; font-family:'Montserrat',Arial,sans-serif; font-size:15px; padding:16px 24px 15px 24px; text-decoration:none; text-transform:uppercase"><strong>TROCAR MINHA SENHA</strong></a></td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
  <p>Caso você não tenha solicitado esta alteração de senha, por favor desconsidere esta mensagem, nenhuma alteração foi feita na sua conta.</p>
  <p>Dúvidas? Acesse <a href="https://www.votolegal.org.br/faq" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
  Equipe Voto Legal</strong><a href="mailto:contato@votolegal.org.br" target="_blank" style="color:#4ab957"></a></td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
  <tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Voto Legal</strong>- Eleições limpas e transparentes. </span></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>

</div>
</div></div>

</body>
</html>

