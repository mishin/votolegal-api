-- Deploy votolegal:0022-cielo-merchant to pg
-- requires: 0021-responsible

BEGIN;

ALTER TABLE candidate DROP COLUMN cielo_token ;

ALTER TABLE candidate ADD COLUMN cielo_merchant_id TEXT ;
ALTER TABLE candidate ADD COLUMN cielo_merchant_key TEXT ;

COMMIT;
