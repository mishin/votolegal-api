-- Deploy votolegal:0100-add-payment_id-on-notification to pg
-- requires: 0099-add-collect-donor-data

BEGIN;

ALTER TABLE payment_notification ADD COLUMN payment_id INTEGER REFERENCES payment(id);

COMMIT;
