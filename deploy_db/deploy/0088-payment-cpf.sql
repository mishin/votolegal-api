-- Deploy votolegal:0088-payment-cpf to pg
-- requires: 0087-payment-log

BEGIN;

ALTER TABLE payment DROP COLUMN cpf;

COMMIT;
