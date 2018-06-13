-- Deploy votolegal:0133-default-theme to pg
-- requires: 0132-procob

BEGIN;

ALTER TABLE candidate ALTER COLUMN color SET default  'theme--default';

COMMIT;
