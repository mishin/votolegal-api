-- Deploy votolegal:0093-fix-refund-logic to pg
-- requires: 0092-add-new-political-movements

BEGIN;

INSERT INTO fsm_transition (fsm_class, from_state, transition, to_state)
    VALUES
('payment', 'register_capture',  'refunded', 'refunded'),
('payment', 'pending_registration',  'refunded', 'refunded');


insert into fsm_state (fsm_class, "name")
values ('payment', 'start_cc_payment');

update fsm_state set "name" = 'certificate_refused' where "name" = 'refused';

delete from fsm_transition where transition = 'cc_authorized';
delete from fsm_transition where transition = 'cc_not_authorized';

INSERT INTO fsm_transition (fsm_class, from_state, transition, to_state)
    VALUES
('payment', 'create_invoice',  'credit_card_added', 'start_cc_payment'),
('payment', 'start_cc_payment',  'cc_authorized', 'capture_cc'),
('payment', 'start_cc_payment',  'cc_not_authorized', 'not_authorized'),
('payment', 'certificate_refused',  'pay_with_cc', 'create_invoice');


update fsm_transition set to_state = 'error_manual_check' where transition = 'error' and from_state= 'capture_cc';

update fsm_transition set to_state = 'certificate_refused' where to_state = 'refused';
update fsm_transition set from_state = 'certificate_refused' where from_state = 'refused';


update fsm_transition set transition = 'AuthorizationNeeded' where transition = 'is_boleto';
update fsm_transition set transition = 'AuthorizationNotNeeded' where transition = 'is_cc';


COMMIT;
