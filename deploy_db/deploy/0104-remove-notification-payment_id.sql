-- Deploy votolegal:0104-remove-notification-payment_id to pg
-- requires: 0103-really-_immutable

BEGIN;

ALTER TABLE payment_notification DROP COLUMN payment_id ;

COMMIT;
