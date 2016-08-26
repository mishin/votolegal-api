-- Deploy votolegal:0061-donation-crawl to pg
-- requires: 0060-donation-crawl

BEGIN;

alter table donation add column species text not null default 'Cartão de crédito';
alter table donation alter column species drop not null ;

alter table donation add column by_votolegal boolean default 't';
alter table donation alter column by_votolegal drop default ;

COMMIT;
