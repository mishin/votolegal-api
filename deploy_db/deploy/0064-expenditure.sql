-- Deploy votolegal:0064-expenditure to pg
-- requires: 0063-dv-alfanum

BEGIN;

CREATE TABLE expenditure (
    id              serial primary key,
    candidate_id    integer not null references candidate(id),
    name            text not null,
    cnpj            text not null,
    amount          integer not null,
    type            text not null,
    document_number text not null,
    resource_specie text not null,
    document_specie text not null,
    date            date not null,
    created_at      timestamp without time zone not null default now()
);

COMMIT;
