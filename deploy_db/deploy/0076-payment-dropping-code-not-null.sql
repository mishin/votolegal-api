-- Deploy votolegal:0076-payment-dropping-code-not-null to pg
-- requires: 0075-payment-method

BEGIN;

ALTER TABLE payment ALTER COLUMN code DROP NOT NULL;

COMMIT;
