-- Deploy votolegal:0126-add-running_for_address_state to pg
-- requires: 0125-remove-unused-states

BEGIN;

ALTER TABLE candidate ADD COLUMN running_for_address_state TEXT;


COMMIT;
