-- Deploy votolegal:0043-merchant to pg
-- requires: 0042-new-issue-priorities

BEGIN;

alter table candidate rename column cielo_merchant_id to merchant_id ;
alter table candidate rename column cielo_merchant_key to merchant_key ;

COMMIT;
