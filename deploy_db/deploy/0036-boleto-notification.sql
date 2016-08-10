-- Deploy votolegal:0036-boleto-notification to pg
-- requires: 0035-boleto

BEGIN;

CREATE TABLE payment_notification (
    notification_code text not null,
    notification_type text not null,
    created_at       timestamp without time zone not null default now()
);

COMMIT;
