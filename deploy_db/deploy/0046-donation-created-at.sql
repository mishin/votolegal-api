-- Deploy votolegal:0046-donation-created-at to pg
-- requires: 0045-payment-notification-type

BEGIN;

ALTER TABLE donation ADD COLUMN created_at timestamp without time zone not null default now() ;

COMMIT;
