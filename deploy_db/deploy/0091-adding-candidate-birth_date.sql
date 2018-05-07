-- Deploy votolegal:0091-adding-candidate-birth_date to pg
-- requires: 0090-deleting-offices

BEGIN;

ALTER TABLE candidate ADD COLUMN birth_date TEXT;
UPDATE candidate SET birth_date = '';
ALTER TABLE candidate ALTER COLUMN birth_date SET NOT NULL;

COMMIT;
