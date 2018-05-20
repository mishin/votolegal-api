-- Deploy votolegal:0116-remove-decred-old-hash to pg
-- requires: 0115-donation-decred

BEGIN;

alter table  votolegal_donation drop column decred_refund_hash ;
alter table  votolegal_donation drop column decred_refund_registered_at;




COMMIT;
