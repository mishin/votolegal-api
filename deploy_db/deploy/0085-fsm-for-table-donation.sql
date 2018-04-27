-- Deploy votolegal:0085-fsm-for-table-donation to pg
-- requires: 0084-default-color

BEGIN;

CREATE TABLE fsm_state (
    fsm_class text NOT NULL,
    "name" text NOT NULL,
    auto_continue boolean not null default false,
    PRIMARY KEY (fsm_class, "name")
);

CREATE TABLE fsm_transition (
    fsm_class text NOT NULL,
    from_state text NOT NULL,
    transition text NOT NULL ,
    to_state text NOT NULL,
    PRIMARY KEY (fsm_class, from_state, to_state)
);


INSERT INTO fsm_transition (fsm_class, from_state, transition, to_state)
    VALUES
('payment', 'created',      'is_boleto', 'boleto_authentication'),
('payment', 'created',      'is_cc', 'create_invoice'),
('payment', 'boleto_authentication',      'human_verified', 'create_invoice'),
('payment', 'boleto_authentication',      'not_human', 'refused'),

('payment', 'create_invoice',      'cc_not_authorized', 'not_authorized'),
('payment', 'create_invoice',      'cc_authorized', 'capture_cc'),

('payment', 'capture_cc',      'captured', 'register_capture'),
('payment', 'capture_cc',      'error', 'refused'),

('payment', 'create_invoice',      'boleto_generated', 'waiting_boleto_payment'),
('payment', 'waiting_boleto_payment',      'boleto_paid', 'validate_payment'),
('payment', 'waiting_boleto_payment',      'due_reached', 'boleto_expired'),
('payment', 'validate_payment',      'paid_amount_ok', 'register_capture'),
('payment', 'validate_payment',      'not_acceptable', 'error_manual_check'),

('payment', 'register_capture',      'ok', 'wait_for_compensation'),

('payment', 'wait_for_compensation',      'done', 'transfer_money'),
('payment', 'register_capture',      'error', 'pending_registration'),

('payment', 'transfer_money',      'transferred', 'transfer_done'),
('payment', 'transfer_money',      'error', 'pending_transfer'),
('payment', 'pending_transfer',      'try_again', 'transfer_money'),

('payment', 'pending_registration',      'try_again', 'register_capture'),
('payment', 'transfer_done',      'refunded', 'register_refund'),
('payment', 'wait_for_compensation',      'refunded', 'register_refund'),
('payment', 'register_refund',      'ok', 'refunded'),
('payment', 'register_refund',      'error', 'pending_refund_register'),
('payment', 'pending_refund_register',      'try_again', 'register_refund');



insert into fsm_state (fsm_class, "name")
select fsm_class, from_state
from fsm_transition
group by 1, 2
union
select fsm_class, to_state
from fsm_transition
group by 1, 2
;

alter table "donation" add column state varchar not null default 'created';


COMMIT;
