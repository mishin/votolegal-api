-- Deploy votolegal:0057-payment-gateway-code to pg
-- requires: 0056-remove-ficha-limpa

BEGIN;

alter table donation add column payment_gateway_code text;

COMMIT;
