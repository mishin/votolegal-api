-- Deploy votolegal:0131-add-fb_chat_plugin_code to pg
-- requires: 0130-add-political-movement

BEGIN;

ALTER TABLE candidate_mandato_aberto_integration ADD COLUMN fb_chat_plugin_code TEXT, ADD COLUMN id SERIAL PRIMARY KEY;

COMMIT;
