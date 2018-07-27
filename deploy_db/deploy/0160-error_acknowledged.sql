-- Deploy votolegal:0160-error_acknowledged to pg
-- requires: 0159-add-retry-config

BEGIN;

alter table votolegal_donation add column error_acknowledged boolean;

COMMIT;
