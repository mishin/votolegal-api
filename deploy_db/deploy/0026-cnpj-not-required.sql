-- Deploy votolegal:0026-cnpj-not-required to pg
-- requires: 0025-project-votes

BEGIN;

ALTER TABLE candidate ALTER COLUMN cnpj DROP NOT NULL ;

COMMIT;
