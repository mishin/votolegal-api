-- Deploy votolegal:0013-issue-priority to pg
-- requires: 0012-candidate-cnpj

BEGIN;

CREATE TABLE issue_priority (
    id      SERIAL PRIMARY KEY,
    name    TEXT NOT NULL
);

INSERT INTO issue_priority (name) VALUES ('Saúde'), ('Educação'), ('Meio Ambiente'), ('Economia'), ('Turismo');

CREATE TABLE candidate_issue_priority (
    candidate_id      INTEGER REFERENCES candidate(id),
    issue_priority_id INTEGER REFERENCES issue_priority(id),
    CONSTRAINT candidate_issue_priority_pkey PRIMARY KEY (candidate_id, issue_priority_id)
);

COMMIT;
