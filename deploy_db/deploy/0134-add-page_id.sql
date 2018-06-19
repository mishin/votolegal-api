-- Deploy votolegal:0134-add-page_id to pg
-- requires: 0133-default-theme

BEGIN;

ALTER TABLE candidate_mandato_aberto_integration ADD COLUMN page_id TEXT;
UPDATE candidate_mandato_aberto_integration SET page_id = '';
ALTER TABLE candidate_mandato_aberto_integration ALTER COLUMN page_id SET NOT NULL;

ALTER TABLE candidate_mandato_aberto_integration DROP COLUMN fb_chat_plugin_code;

COMMIT;
