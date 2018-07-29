-- Deploy votolegal:0162-donation-dcrtime-timestamp to pg
-- requires: 0161-fix-candidate_campaign_config

BEGIN;

ALTER TABLE votolegal_donation ADD COLUMN dcrtime_timestamp TIMESTAMP WITHOUT TIME ZONE;

COMMIT;
