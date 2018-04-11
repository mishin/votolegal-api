-- Deploy votolegal:0075-payment-method to pg
-- requires: 0074-contract-signature

BEGIN;

ALTER TABLE payment DROP COLUMN boleto_url, ADD COLUMN method TEXT;

COMMIT;
