-- Deploy votolegal:0048-candidate-bank to pg
-- requires: 0047-bank-list

BEGIN;

alter table candidate add column bank_code integer references bank(id) ;
alter table candidate add column bank_agency integer ;
alter table candidate add column bank_account_number integer ;
alter table candidate add column bank_account_dv integer ;

COMMIT;
