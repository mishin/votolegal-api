-- Deploy votolegal:0078-add-id-to-payment to pg
-- requires: 0077-payment-data

BEGIN;

ALTER TABLE payment ADD COLUMN id SERIAL PRIMARY KEY;
CREATE TABLE payment_history (
    id                   SERIAL    PRIMARY KEY,
    code                 TEXT      NOT NULL,
    action               TEXT      NOT NULL,
    sender_hash          TEXT      NOT NULL,
    method               TEXT      NOT NULL,
    name                 TEXT      NOT NULL,
    email                TEXT      NOT NULL,
    address_state        TEXT      NOT NULL,
    address_city         TEXT      NOT NULL,
    address_zipcode      TEXT      NOT NULL,
    address_district     TEXT      NOT NULL,
    address_street       TEXT      NOT NULL,
    address_house_number INTEGER   NOT NULL,
    address_complement   TEXT,
    cpf                  TEXT      NOT NULL,
    phone                TEXT      NOT NULL,
    created_at           TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
