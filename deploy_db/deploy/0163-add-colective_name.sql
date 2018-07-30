-- Deploy votolegal:0163-add-colective_name to pg
-- requires: 0162-donation-dcrtime-timestamp

BEGIN;

ALTER TABLE candidate ADD COLUMN colective_name TEXT;

COMMIT;
