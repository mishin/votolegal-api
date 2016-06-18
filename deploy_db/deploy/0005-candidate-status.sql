-- Deploy votolegal:0005-candidate-status to pg
-- requires: 0004-party-acronym

BEGIN;

ALTER TABLE candidate DROP COLUMN active ;
ALTER TABLE candidate ADD COLUMN status TEXT NOT NULL DEFAULT 'pending' CHECK (status::text = ANY(ARRAY['pending', 'activated', 'deactivated']));
ALTER TABLE candidate ALTER COLUMN status DROP DEFAULT;

COMMIT;
