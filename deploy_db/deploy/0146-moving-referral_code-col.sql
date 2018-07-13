-- Deploy votolegal:0146-moving-referral_code-col to pg
-- requires: 0145-add-referral-table

BEGIN;

ALTER TABLE votolegal_donation DROP COLUMN referral_code;
ALTER TABLE votolegal_donation_immutable ADD COLUMN referral_code TEXT REFERENCES referral(code);

COMMIT;
