-- Deploy votolegal:0006-delete-raising-goal to pg
-- requires: 0005-candidate-status

BEGIN;

ALTER TABLE candidate DROP COLUMN raising_goal ;

COMMIT;
