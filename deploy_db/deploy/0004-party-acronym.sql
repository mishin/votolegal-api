-- Deploy votolegal:0004-party-acronym to pg
-- requires: 0003-names

BEGIN;

ALTER TABLE party ADD COLUMN acronym TEXT NOT NULL DEFAULT '' ;
ALTER TABLE party ALTER COLUMN acronym DROP DEFAULT ;

COMMIT;
