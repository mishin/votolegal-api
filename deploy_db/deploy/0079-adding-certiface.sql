-- Deploy votolegal:0079-adding-certiface to pg
-- requires: 0078-add-id-to-payment

BEGIN;

CREATE TABLE certiface_token (
    id         SERIAL    PRIMARY KEY,
    uuid       TEXT      NOT NULL,
    succeeded  boolean   NOT NULL DEFAULT false,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE
);
ALTER TABLE donation ADD COLUMN certiface_token_id INTEGER REFERENCES certiface_token(id);

COMMIT;
