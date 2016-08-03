-- Deploy votolegal:0032-payment-status to pg
-- requires: 0031-issue-priorities-fix

BEGIN;

ALTER TABLE candidate ADD COLUMN payment_status text not null default 'unpaid' check(payment_status::text = ANY(ARRAY['unpaid', 'paid']));

COMMIT;
