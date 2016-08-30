-- Deploy votolegal:0065-no-receipt to pg
-- requires: 0064-expenditure

BEGIN;

alter table candidate drop column receipt_min ;
alter table candidate drop column receipt_max ;
alter table donation drop column receipt_id ;

COMMIT;
