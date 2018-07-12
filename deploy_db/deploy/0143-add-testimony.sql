-- Deploy votolegal:0143-add-testimony to pg
-- requires: 0142-add-jenkins_auth-env

BEGIN;

CREATE TABLE testimony (
    id               SERIAL PRIMARY KEY,
    candidate_id     INTEGER REFERENCES candidate(id) NOT NULL,
    reviewer_picture TEXT,
    reviewer_name    TEXT NOT NULL,
    reviewer_text    TEXT NOT NULL,
    active           BOOLEAN NOT NULL DEFAULT true,
    created_at       TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
