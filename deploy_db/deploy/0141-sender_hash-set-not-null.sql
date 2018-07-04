-- Deploy votolegal:0141-sender_hash-set-not-null to pg
-- requires: 0140-fix-license-envs

BEGIN;

ALTER TABLE payment ALTER COLUMN sender_hash DROP NOT NULL;

COMMIT;
