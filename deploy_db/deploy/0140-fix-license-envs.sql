-- Deploy votolegal:0140-fix-license-envs to pg
-- requires: 0139-license-envs

BEGIN;

UPDATE config SET value = 'env' WHERE name IN ( 'VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID', 'VOTOLEGAL_LICENSE_IUGU_API_KEY' );

COMMIT;
