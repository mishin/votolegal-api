-- Deploy votolegal:0045-payment-notification-type to pg
-- requires: 0044-payment-gateway

BEGIN;

alter table payment_notification drop column notification_type ;

COMMIT;
