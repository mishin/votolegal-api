-- Deploy votolegal:0038-donation-birthdate to pg
-- requires: 0037-telefone-bairro

BEGIN;

alter table donation add column birthdate date not null default date(now()) ;
alter table donation alter column birthdate drop default ;

COMMIT;
