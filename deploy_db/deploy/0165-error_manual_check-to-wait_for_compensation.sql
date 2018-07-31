-- Deploy votolegal:0165-error_manual_check-to-wait_for_compensation to pg
-- requires: 0164-update-bank-data

BEGIN;

delete from fsm_transition where from_state = 'capture_cc' and  transition = 'captured';
INSERT INTO fsm_transition (fsm_class, from_state, transition, to_state)
    VALUES
('payment', 'error_manual_check',  'GatewayInfoUpdated', 'validate_payment'),
('payment', 'capture_cc',  'captured', 'validate_payment');


COMMIT;
