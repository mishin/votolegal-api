-- Deploy votolegal:0165-add-envs to pg
-- requires: 0164-update-bank-data

BEGIN;

INSERT INTO config (name, value) VALUES ('PRE_CAMPAIGN_END_DATE_FOR_LICENSE', '2018-08-14'), ('CAMPAIGN_START_DATE_FOR_LICENSE', '2018-08-15');


COMMIT;
