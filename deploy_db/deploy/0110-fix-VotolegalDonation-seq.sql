-- Deploy votolegal:0110-fix-VotolegalDonation-seq to pg
-- requires: 0109-config-table

BEGIN;

ALTER TABLE public.votolegal_donation
   ALTER COLUMN id SET DEFAULT uuid_generate_v1();

COMMIT;
