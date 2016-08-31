-- Deploy votolegal:0066-slack-queue to pg
-- requires: 0065-no-receipt

BEGIN;

CREATE TABLE slack_queue (
  id         SERIAL PRIMARY KEY,
  channel    text not null,
  message    text not null,
  created_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMIT;
