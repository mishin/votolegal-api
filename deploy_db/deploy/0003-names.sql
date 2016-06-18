-- Deploy votolegal:0003-names to pg
-- requires: 0002-reelection

BEGIN;

ALTER TABLE candidate ALTER COLUMN name SET NOT NULL ;
ALTER TABLE candidate ALTER COLUMN popular_name SET NOT NULL ;

COMMIT;
