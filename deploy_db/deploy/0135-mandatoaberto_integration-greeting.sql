-- Deploy votolegal:0135-mandatoaberto_integration-greeting to pg
-- requires: 0134-add-page_id

BEGIN;

ALTER TABLE candidate_mandato_aberto_integration ADD COLUMN greeting TEXT;

COMMIT;
