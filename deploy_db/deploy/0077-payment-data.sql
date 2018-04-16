-- Deploy votolegal:0077-payment-data to pg
-- requires: 0076-payment-dropping-code-not-null

BEGIN;

ALTER TABLE payment
    ADD COLUMN name                 TEXT,
    ADD COLUMN email                TEXT,
    ADD COLUMN address_state        TEXT,
    ADD COLUMN address_city         TEXT,
    ADD COLUMN address_zipcode      TEXT,
    ADD COLUMN address_district     TEXT,
    ADD COLUMN address_street       TEXT,
    ADD COLUMN address_complement   TEXT,
    ADD COLUMN address_house_number INTEGER,
    ADD COLUMN cpf                  TEXT,
    ADD COLUMN phone                TEXT;

COMMIT;
