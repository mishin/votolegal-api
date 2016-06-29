-- Deploy votolegal:0020-public-info to pg
-- requires: 0019-raising-goal

BEGIN;

ALTER TABLE candidate ADD COLUMN public_email TEXT ;

ALTER TABLE candidate ADD COLUMN spending_spreadsheet TEXT ;

COMMIT;
