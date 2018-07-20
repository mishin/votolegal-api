-- Deploy votolegal:0152-add-has_custom_site to pg
-- requires: 0151-split_rule_id

BEGIN;

ALTER TABLE candidate ADD COLUMN has_custom_site BOOLEAN NOT NULL DEFAULT false;

COMMIT;
