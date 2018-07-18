-- Deploy votolegal:0149-add-env to pg
-- requires: 0148-add-dcrtime-auth

BEGIN;

INSERT INTO config (name, value) VALUES ( 'FRONT_URL', 'env' );

COMMIT;
