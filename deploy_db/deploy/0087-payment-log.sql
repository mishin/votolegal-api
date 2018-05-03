-- Deploy votolegal:0087-payment-log to pg
-- requires: 0086-device-auth

BEGIN;

DROP TABLE payment_history;
CREATE TABLE payment_log(
    payment_id INTEGER   REFERENCES payment(id) NOT NULL,
    status     TEXT      NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
