-- Deploy votolegal:0125-remove-unused-states to pg
-- requires: 0124-uuid_generate_v1mc

BEGIN;

delete from fsm_state where "name" in (
'pending_registration',
'pending_refund_register',
'register_refund',
'transfer_done',
'pending_transfer',
'transfer_money',
'register_capture'
);


update fsm_state set "name" = 'wait_for_compensation' where "name"  = 'register_capture';

update votolegal_donation set state='wait_for_compensation' where state='register_capture';

delete from fsm_transition where from_state in (
'pending_registration',
'pending_refund_register',
'register_refund',
'transfer_done',
'pending_transfer',
'transfer_money',
'register_capture'
);
delete from fsm_transition where to_state in (
'pending_registration',
'pending_refund_register',
'register_refund',
'transfer_done',
'pending_transfer',
'transfer_money',
'register_capture'
);

insert into fsm_state  (fsm_class, name) values ('payment','done');


INSERT INTO fsm_transition (fsm_class, from_state, transition, to_state)
    VALUES
('payment', 'capture_cc',  'captured', 'wait_for_compensation'),
('payment', 'wait_for_compensation',  'refunded', 'refunded'),
('payment', 'wait_for_compensation',  'ok', 'done'),
('payment', 'done',  'refunded', 'refunded'),
('payment', 'validate_payment',  'paid_amount_ok', 'wait_for_compensation')
;



COMMIT;
