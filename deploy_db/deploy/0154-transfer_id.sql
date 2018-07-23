-- Deploy votolegal:0154-transfer_id to pg
-- requires: 0153-julios_status

BEGIN;

alter table votolegal_donation add column julios_transfer_id int;

COMMIT;
