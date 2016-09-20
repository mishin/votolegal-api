-- Deploy votolegal:0072-donation-payment-gateway-id to pg
-- requires: 0071-donation-canceled

BEGIN;

alter table donation add column payment_gateway_id integer not null references payment_gateway(id) default 2;
alter table donation alter column payment_gateway_id drop default ;

COMMIT;
