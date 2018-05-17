-- Deploy votolegal:0102-DeviceAuthorizationToken to pg
-- requires: 0101-unaccent

BEGIN;

alter table Device_Authorization_Token add column can_create_boleto_without_certiface boolean not null default false;


alter table votolegal_donation drop column certiface_token_id;

DROP TABLE public.certiface_token cascade;

CREATE TABLE public.certiface_token
(
  id uuid primary key NOT NULL,
  verification_url varchar not null,
  votolegal_donation_id uuid references votolegal_donation(id),
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  validated boolean not null default false,

  fail_reasons json,
  response_updated_at timestamp without time zone,
  response json
);

--  nao precisa ter esse controle todo , é só pro lock

ALTER TABLE public.votolegal_donation_immutable DROP CONSTRAINT votolegal_donation_immutable_donor_cpf_fkey;

COMMIT;
