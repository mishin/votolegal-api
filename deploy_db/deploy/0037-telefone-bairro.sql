-- Deploy votolegal:0037-telefone-bairro to pg
-- requires: 0036-boleto-notification

BEGIN;

alter table candidate add column phone text ;
alter table candidate add column address_district text ;

COMMIT;
