-- Deploy votolegal:0074-contract-signature to pg
-- requires: 0073-update-office-party

BEGIN;

CREATE TABLE contract_signature (
    id           SERIAL    PRIMARY KEY,
    user_id      INTEGER   NOT NULL REFERENCES "user"(id),
    ip_address   TEXT      NOT NULL,
    signed_at    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
