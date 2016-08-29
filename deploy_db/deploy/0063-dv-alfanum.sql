-- Deploy votolegal:0063-dv-alfanum to pg
-- requires: 0062-donation-receipt-id-tse

BEGIN;

alter table candidate alter column bank_account_dv type varchar(2) ;
alter table candidate alter column bank_agency_dv type varchar(2) ;

COMMIT;
