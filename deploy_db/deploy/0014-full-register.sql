-- Deploy votolegal:0014-full-register to pg
-- requires: 0013-issue-priority

BEGIN;

ALTER TABLE candidate ADD COLUMN picture TEXT ;
ALTER TABLE candidate ADD COLUMN video_url TEXT;
ALTER TABLE candidate ADD COLUMN facebook_url TEXT;
ALTER TABLE candidate ADD COLUMN twitter_url TEXT;
ALTER TABLE candidate ADD COLUMN website_url TEXT;
ALTER TABLE candidate ADD COLUMN summary TEXT;
ALTER TABLE candidate ADD COLUMN biography TEXT;
ALTER TABLE candidate ADD COLUMN cielo_token TEXT;

COMMIT;
