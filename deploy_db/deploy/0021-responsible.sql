-- Deploy votolegal:0021-responsible to pg
-- requires: 0020-public-info

BEGIN;

ALTER TABLE candidate ADD COLUMN responsible_name TEXT ;
ALTER TABLE candidate ADD COLUMN responsible_email TEXT ;

COMMIT;
