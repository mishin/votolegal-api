-- Deploy votolegal:0023-donation to pg
-- requires: 0022-cielo-merchant

BEGIN;

CREATE TABLE donation (
    id           SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidate(id),
    name         TEXT NOT NULL,
    email        TEXT NOT NULL,
    cpf          TEXT NOT NULL,
    phone        TEXT,
    amount       INTEGER NOT NULL,  
    status       TEXT NOT NULL CHECK (status::text = ANY(ARRAY['created', 'tokenized', 'authorized', 'captured']))
);

COMMIT;
