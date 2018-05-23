-- Deploy votolegal:0124-uuid_generate_v1mc to pg
-- requires: 0123-audit-tables

BEGIN;

ALTER TABLE public.votolegal_donation
   ALTER COLUMN id SET DEFAULT uuid_generate_v1mc();

COMMIT;
