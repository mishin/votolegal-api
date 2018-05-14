-- Deploy votolegal:0098-candidate-google-analytics to pg
-- requires: 0097-boleto-auto-cp

BEGIN;

ALTER TABLE candidate ADD COLUMN google_analytics TEXT;

COMMIT;
