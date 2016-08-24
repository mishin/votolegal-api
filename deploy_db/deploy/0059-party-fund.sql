-- Deploy votolegal:0059-party-fund to pg
-- requires: 0058-donation-chargeback

BEGIN;

alter table candidate add column party_fund integer;

COMMIT;
