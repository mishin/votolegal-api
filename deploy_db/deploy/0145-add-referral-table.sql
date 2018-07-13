-- Deploy votolegal:0145-add-referral-table to pg
-- requires: 0144-adding-one-more-movement

BEGIN;

CREATE TABLE referral (
    code                  TEXT      NOT NULL PRIMARY KEY,
    candidate_id          INTEGER   REFERENCES candidate(id) NOT NULL,
    created_at            TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);
ALTER TABLE votolegal_donation ADD COLUMN referral_code TEXT REFERENCES referral(code);

COMMIT;
