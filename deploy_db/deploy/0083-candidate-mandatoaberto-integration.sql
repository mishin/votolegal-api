-- Deploy votolegal:0083-candidate-mandatoaberto-integration to pg
-- requires: 0082-adding-candidate-color

BEGIN;

CREATE TABLE candidate_mandato_aberto_integration (
    candidate_id     INTEGER   REFERENCES candidate(id) NOT NULL,
    mandatoaberto_id INTEGER   NOT NULL,
    created_at       TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

COMMIT;
