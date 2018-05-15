-- Deploy votolegal:0099-add-collect-donor-data to pg
-- requires: 0098-candidate-google-analytics

BEGIN;

ALTER TABLE candidate ADD COLUMN collect_donor_address BOOLEAN NOT NULL DEFAULT TRUE, ADD COLUMN collect_donor_phone BOOLEAN NOT NULL DEFAULT TRUE;

COMMIT;
