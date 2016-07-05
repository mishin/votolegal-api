-- Deploy votolegal:0024-donation-hash to pg
-- requires: 0023-donation

BEGIN;

ALTER TABLE donation ALTER COLUMN id TYPE VARCHAR(32);
ALTER TABLE donation ALTER COLUMN id DROP DEFAULT ;

COMMIT;
