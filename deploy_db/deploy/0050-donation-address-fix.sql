-- Deploy votolegal:0050-donation-address-fix to pg
-- requires: 0049-donation-address

BEGIN;

alter table donation alter column address_complement drop not null;
alter table donation alter column billing_address_complement drop not null;
alter table donation add column address_district text not null ;

COMMIT;
