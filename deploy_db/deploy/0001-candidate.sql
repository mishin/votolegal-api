-- Deploy votolegal:0001-candidate to pg
-- requires: 0000-party

BEGIN;

CREATE TABLE public.candidate
(
    id           SERIAL PRIMARY KEY,
    user_id      INTEGER NOT NULL REFERENCES "user"(id),
    name         text NOT NULL,
    popular_name text NOT NULL,
    party_id     INTEGER NOT NULL REFERENCES party(id),
    cpf          text NOT NULL UNIQUE,
    ficha_limpa  boolean NOT NULL,
    reelection   boolean NOT NULL,
    active       boolean DEFAULT false,
    raising_goal integer NOT NULL
);

CREATE TABLE public.office (
    id      SERIAL PRIMARY KEY,
    name    TEXT UNIQUE
);

INSERT INTO office (name) VALUES ('Prefeito'), ('Vereador') ;

ALTER TABLE candidate ADD COLUMN office_id INTEGER NOT NULL DEFAULT 1 REFERENCES office(id) ;
ALTER TABLE candidate ALTER COLUMN office_id DROP DEFAULT ;

COMMIT;
