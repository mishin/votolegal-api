-- Deploy votolegal:0147-add-custom_url to pg
-- requires: 0146-moving-referral_code-col

BEGIN;

ALTER TABLE candidate ADD COLUMN custom_url TEXT;

COMMIT;
