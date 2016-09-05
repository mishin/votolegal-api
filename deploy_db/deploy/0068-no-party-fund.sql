-- Deploy votolegal:0068-no-party-fund to pg
-- requires: 0067-expenditure-cpf

BEGIN;

create table donation_type (
    id      serial primary key,
    name    text not null
);

insert into donation_type (name) values ('Pessoa Física'), ('Fundo Partidário');

alter table donation add column donation_type_id integer not null references donation_type(id) default 1 ;
alter table donation alter column donation_type_id drop default ;

alter table candidate drop column party_fund ;

COMMIT;
