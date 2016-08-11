-- Deploy votolegal:0039-receipt to pg
-- requires: 0038-donation-birthdate

BEGIN;

alter table candidate add column receipt_min integer;
alter table candidate add column receipt_max integer;

alter table donation add column receipt_id integer not null;

COMMIT;
