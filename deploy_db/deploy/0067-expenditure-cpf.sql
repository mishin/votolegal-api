-- Deploy votolegal:0067-expenditure-cpf to pg
-- requires: 0066-slack-queue

BEGIN;

alter table expenditure rename column cnpj to cpf_cnpj ;

COMMIT;
