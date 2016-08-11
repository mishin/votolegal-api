-- Deploy votolegal:0040-donation-transaction-hash to pg
-- requires: 0039-receipt

BEGIN;

alter table donation add column transaction_hash text ;

COMMIT;
