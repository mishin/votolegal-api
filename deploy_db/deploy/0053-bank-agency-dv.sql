-- Deploy votolegal:0053-bank-agency-dv to pg
-- requires: 0052-add-issue-priority

BEGIN;

alter table candidate add column bank_agency_dv smallint;

COMMIT;
