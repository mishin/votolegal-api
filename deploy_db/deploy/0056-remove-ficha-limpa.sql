-- Deploy votolegal:0056-remove-ficha-limpa to pg
-- requires: 0055-issue-priority

BEGIN;

alter table candidate drop column ficha_limpa ;

COMMIT;
