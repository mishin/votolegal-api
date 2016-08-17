-- Deploy votolegal:0051-donation-address-default to pg
-- requires: 0050-donation-address-fix

BEGIN;

alter table donation alter column address_complement drop default ;

COMMIT;
