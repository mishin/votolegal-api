-- Deploy votolegal:0002-reelection to pg
-- requires: 0001-candidate

BEGIN;

ALTER TABLE candidate DROP COLUMN ficha_limpa ;

COMMIT;
