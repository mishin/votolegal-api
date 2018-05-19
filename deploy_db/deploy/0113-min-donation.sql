-- Deploy votolegal:0113-min-donation to pg
-- requires: 0112-emaildb

BEGIN;

alter table candidate add column min_donation_value int not null default 2000;

COMMIT;
