-- Deploy votolegal:0127-add-publish-timestamps to pg
-- requires: 0126-add-running_for_address_state

BEGIN;

ALTER TABLE candidate ADD COLUMN published_at TIMESTAMP WITHOUT TIME ZONE, ADD COLUMN unpublished_at TIMESTAMP WITHOUT TIME ZONE;

COMMIT;
