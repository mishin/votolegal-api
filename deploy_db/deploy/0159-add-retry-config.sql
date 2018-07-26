-- Deploy votolegal:0159-add-retry-config to pg
-- requires: 0158-fix-timezone

BEGIN;

INSERT INTO config (name, value) VALUES ('MAX_RETRY_WINDOW_IN_SECONDS', '80');

COMMIT;
