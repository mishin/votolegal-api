-- Deploy votolegal:0081-donation_log to pg
-- requires: 0080-add-payment_gateway

BEGIN;

CREATE TABLE donation_log (
    donation_id       VARCHAR(32) REFERENCES donation(id) NOT NULL,
    status            TEXT        NOT NULL,
    status_updated_at TIMESTAMP   WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
