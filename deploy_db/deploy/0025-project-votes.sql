-- Deploy votolegal:0025-project-votes to pg
-- requires: 0024-donation-hash

BEGIN;

CREATE TABLE project_vote (
    id           SERIAL PRIMARY KEY,
    donation_id  VARCHAR(32) NOT NULL REFERENCES donation(id),
    project_id   INTEGER NOT NULL REFERENCES project(id)
);

COMMIT;
