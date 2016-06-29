-- Deploy votolegal:0019-raising-goal to pg
-- requires: 0018-instagram

BEGIN;

ALTER TABLE candidate ADD COLUMN raising_goal NUMERIC(11, 2) ;

COMMIT;
