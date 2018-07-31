-- Deploy votolegal:0166-add-is_pre_campaign to pg
-- requires: 0165-add-envs

BEGIN;

ALTER TABLE contract_signature ADD COLUMN is_pre_campaign BOOLEAN DEFAULT true;

COMMIT;
