-- Deploy votolegal:0015-unused-email-queue-columns to pg
-- requires: 0014-full-register

BEGIN;

CREATE TABLE email_queue
(
  id         SERIAL PRIMARY KEY,
  user_id    integer REFERENCES "user"(id),
  body       text NOT NULL,
  sent       boolean DEFAULT false,
  title      text NOT NULL,
  sent_at    timestamp without time zone,
  created_at timestamp without time zone NOT NULL DEFAULT now()
);

ALTER TABLE email_queue DROP COLUMN user_id ;
ALTER TABLE email_queue DROP COLUMN title ;
ALTER TABLE email_queue DROP COLUMN sent ;
ALTER TABLE email_queue DROP COLUMN sent_at ;

COMMIT;
