-- Deploy votolegal:0129-next-gateway-check to pg
-- requires: 0128-add-amounts-on-payment

BEGIN;

alter table votolegal_donation add column next_gateway_check timestamp without time zone not null default 'infinity';

update votolegal_donation set next_gateway_check = now() where is_boleto and gateway_tid is not null and captured_at is null;

COMMIT;
