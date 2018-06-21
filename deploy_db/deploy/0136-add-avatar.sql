-- Deploy votolegal:0136-add-avatar to pg
-- requires: 0135-mandatoaberto_integration-greeting

BEGIN;

ALTER TABLE candidate ADD COLUMN avatar TEXT;

COMMIT;
