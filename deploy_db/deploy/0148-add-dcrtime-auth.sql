-- Deploy votolegal:0148-add-dcrtime-auth to pg
-- requires: 0147-add-custom_url

BEGIN;

INSERT INTO config (name, value) VALUES ('VOTOLEGAL_DCRTIME_USERNAME', 'votolegal'), ('VOTOLEGAL_DCRTIME_PASSWD', '');

COMMIT;
