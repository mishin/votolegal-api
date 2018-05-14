-- Deploy votolegal:0097-boleto-auto-cp to pg
-- requires: 0096-add-auto-cp

BEGIN;

update fsm_state set auto_continue=true where name='validate_payment';


COMMIT;
