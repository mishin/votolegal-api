-- Deploy votolegal:0115-donation-decred to pg
-- requires: 0114-candidate_donation_summary

BEGIN;

ALTER TABLE votolegal_donation ADD COLUMN decred_merkle_root TEXT;
ALTER TABLE votolegal_donation ADD COLUMN decred_merkle_registered_at TIMESTAMP WITHOUT TIME ZONE;
ALTER TABLE votolegal_donation ADD COLUMN decred_data_raw TEXT;
ALTER TABLE votolegal_donation ADD COLUMN decred_data_hash TEXT;
ALTER TABLE votolegal_donation RENAME COLUMN decred_data_hash TO decred_data_digest;

ALTER TABLE votolegal_donation_immutable ADD COLUMN git_hash TEXT NOT NULL;

ALTER TABLE votolegal_donation RENAME COLUMN decred_capture_hash TO decred_capture_txid;

COMMIT;
