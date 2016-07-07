-- Deploy votolegal:0027-ficha-limpa to pg
-- requires: 0026-cnpj-not-required

BEGIN;

ALTER TABLE candidate ADD COLUMN ficha_limpa BOOLEAN NOT NULL DEFAULT TRUE ;
ALTER TABLE candidate ALTER COLUMN ficha_limpa DROP DEFAULT ;

COMMIT;
