-- Deploy votolegal:0082-adding-candidate-color to pg
-- requires: 0081-donation_log

BEGIN;

ALTER TABLE candidate ADD COLUMN color TEXT DEFAULT 'green' NOT NULL;
DROP TABLE donation_log;

COMMIT;
