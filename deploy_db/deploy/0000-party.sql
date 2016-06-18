-- Deploy votolegal:0000-party to pg
-- requires: appschema

BEGIN;

CREATE TABLE public.party
(
    id   SERIAL PRIMARY KEY,
    name text UNIQUE
);

COMMIT;
