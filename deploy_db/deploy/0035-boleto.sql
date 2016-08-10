-- Deploy votolegal:0035-boleto to pg
-- requires: 0034-publish

BEGIN;

CREATE TABLE payment (
    code          text not null,
    candidate_id  integer not null references candidate(id),
    sender_hash   text not null,
    boleto_url    text not null,
    created_at    timestamp without time zone not null default now()
);

COMMIT;
