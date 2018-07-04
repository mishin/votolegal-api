-- Deploy votolegal:0139-license-envs to pg
-- requires: 0138-service_donation

BEGIN;

INSERT INTO config (name, value) VALUES ('VOTOLEGAL_LICENSE_IUGU_ACCOUNT_ID', ''), ('VOTOLEGAL_LICENSE_IUGU_API_KEY', '');

COMMIT;
