-- Deploy votolegal:0034-publish to pg
-- requires: 0033-vice-prefeito

BEGIN;

ALTER TABLE candidate ADD COLUMN publish boolean NOT NULL DEFAULT 'f' ;

COMMIT;
