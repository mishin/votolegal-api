-- Deploy votolegal:0012-candidate-cnpj to pg
-- requires: 0011-populate_party

BEGIN;

ALTER TABLE candidate ADD COLUMN cnpj TEXT NOT NULL DEFAULT '';
ALTER TABLE candidate ALTER COLUMN cnpj DROP DEFAULT ;

COMMIT;
