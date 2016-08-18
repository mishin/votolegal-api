-- Deploy votolegal:0054-donation-paid-at to pg
-- requires: 0053-bank-agency-dv

BEGIN;

alter table donation add column captured_at timestamp without time zone ;

COMMIT;
