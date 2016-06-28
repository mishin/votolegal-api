-- Deploy votolegal:0018-instagram to pg
-- requires: 0017-forgot-password

BEGIN;

ALTER TABLE candidate ADD COLUMN instagram_url TEXT ;

COMMIT;
