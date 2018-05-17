-- Deploy votolegal:0101-unaccent to pg
-- requires: 0100-add-payment_id-on-notification

create extension if not exists unaccent ;