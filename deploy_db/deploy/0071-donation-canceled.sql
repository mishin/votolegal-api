-- Deploy votolegal:0071-donation-canceled to pg
-- requires: 0070-crawlable

BEGIN;

alter table donation drop constraint donation_status_check;
alter table donation add constraint donation_status_check CHECK(status::text = ANY(ARRAY['created', 'tokenized', 'authorized', 'captured', 'chargeback', 'canceled'])) ;

COMMIT;
