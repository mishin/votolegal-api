-- Deploy votolegal:0016-projects to pg
-- requires: 0015-unused-email-queue-columns

BEGIN;

CREATE TABLE projects (
    id           SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidate(id),
    title        TEXT NOT NULL,
    scope        TEXT NOT NULL
);

COMMIT;
