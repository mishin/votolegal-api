-- Deploy votolegal:0128-add-amounts-on-payment to pg
-- requires: 0127-add-publish-timestamps

BEGIN;

ALTER TABLE payment ADD COLUMN gross_amount TEXT, ADD COLUMN net_amount TEXT, ADD COLUMN fee_amount TEXT;

COMMIT;
