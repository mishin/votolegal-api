-- Deploy votolegal:0096-add-auto-cp to pg
-- requires: 0095-autocp

BEGIN;

update fsm_state set auto_continue=true where name='start_cc_payment' or name='capture_cc';

COMMIT;
