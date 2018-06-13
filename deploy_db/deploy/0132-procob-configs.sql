-- Deploy votolegal:0132-procob-configs to pg
-- requires: 0131-procob

BEGIN;

INSERT INTO config (name, value) VALUES ('PROCOB_ENABLED', '1'), ('PROCOB_AUTH', 'TOKEN'), ('PROCOB_API_URL', 'https://api.procob.com/');


COMMIT;
