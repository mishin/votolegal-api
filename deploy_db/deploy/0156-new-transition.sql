-- Deploy votolegal:0156-new-transition to pg
-- requires: 0155-add-serpro-data

BEGIN;

INSERT INTO fsm_transition (fsm_class, from_state, transition, to_state)
    VALUES
('payment', 'boleto_expired',  'Paid', 'validate_payment');


COMMIT;
