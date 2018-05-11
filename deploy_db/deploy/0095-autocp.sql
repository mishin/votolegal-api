-- Deploy votolegal:0095-autocp to pg
-- requires: 0094-adding-more-options-movement

BEGIN;

update fsm_state set auto_continue=true where name='created';

alter table votolegal_donation add column stash json;

alter table payment_gateway add column class varchar;

update payment_gateway set class= 'IUGU' where name ilike '%iugu%';

update fsm_transition
set to_state = 'waiting_boleto_payment'
where transition = 'human_verified';

delete from fsm_transition
where transition = 'boleto_generated';


update fsm_state set name= 'credit_card_form' where name='create_invoice';

update fsm_transition set to_state = 'credit_card_form' where to_state = 'create_invoice';
update fsm_transition set from_state = 'credit_card_form' where from_state = 'create_invoice';

delete from fsm_transition where from_state = 'created';
INSERT INTO fsm_transition (fsm_class, from_state, transition, to_state)
    VALUES
('payment', 'created',  'BoletoWithoutAuth', 'waiting_boleto_payment'),
('payment', 'created',  'BoletoWithAuth', 'boleto_authentication'),
('payment', 'created',  'CreditCard', 'credit_card_form');


COMMIT;
