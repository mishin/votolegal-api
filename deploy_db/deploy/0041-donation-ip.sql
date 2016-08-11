-- Deploy votolegal:0041-donation-ip to pg
-- requires: 0040-donation-transaction-hash

BEGIN;

alter table donation add column ip_address text not null ;

COMMIT;
