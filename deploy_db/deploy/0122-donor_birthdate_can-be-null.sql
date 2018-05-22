-- Deploy votolegal:0122-donor_birthdate_can-be-null to pg
-- requires: 0121-view-donations

BEGIN;

ALTER TABLE public.votolegal_donation_immutable
   ALTER COLUMN donor_birthdate DROP NOT NULL;

COMMIT;
