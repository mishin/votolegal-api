-- Deploy votolegal:0058-donation-chargeback to pg
-- requires: 0057-payment-gateway-code

BEGIN;

alter table donation drop constraint donation_status_check;
alter table donation add constraint donation_status_check CHECK(status::text = ANY(ARRAY['created', 'tokenized', 'authorized', 'captured', 'chargeback'])) ;

COMMIT;
