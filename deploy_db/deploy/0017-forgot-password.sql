-- Deploy votolegal:0017-forgot-password to pg
-- requires: 0016-projects

BEGIN;

CREATE TABLE user_forgot_password (
    id      SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(id),
    token   VARCHAR(40) NOT NULL,
    valid_until timestamp without time zone NOT NULL
);

COMMIT;
