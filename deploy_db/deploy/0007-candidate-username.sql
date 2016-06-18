-- Deploy votolegal:0007-candidate-username to pg
-- requires: 0006-delete-raising-goal

BEGIN;

ALTER TABLE "user" DROP COLUMN username ;
ALTER TABLE candidate ADD COLUMN username TEXT NOT NULL DEFAULT '';
ALTER TABLE candidate ALTER COLUMN username DROP DEFAULT ;
ALTER TABLE candidate ADD UNIQUE(username) ;

COMMIT;
