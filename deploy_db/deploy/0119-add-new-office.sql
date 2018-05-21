-- Deploy votolegal:0119-add-new-office to pg
-- requires: 0118-fix-existing-captured

BEGIN;

INSERT INTO office (name) VALUES ('Deputado Distrital');

COMMIT;
