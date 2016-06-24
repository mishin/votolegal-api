-- Deploy votolegal:0015-unused-email-queue-columns to pg
-- requires: 0014-full-register

BEGIN;

ALTER TABLE email_queue DROP COLUMN user_id ;
ALTER TABLE email_queue DROP COLUMN title ;
ALTER TABLE email_queue DROP COLUMN sent ;
ALTER TABLE email_queue DROP COLUMN sent_at ;

COMMIT;
