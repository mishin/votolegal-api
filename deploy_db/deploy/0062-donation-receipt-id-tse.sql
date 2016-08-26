-- Deploy votolegal:0062-donation-receipt-id-tse to pg
-- requires: 0061-donation-crawl

BEGIN;

alter table donation alter column receipt_id drop not null;

COMMIT;
