-- Deploy votolegal:0155-add-serpro-data to pg
-- requires: 0154-transfer_id

BEGIN;

INSERT INTO config (name, value) VALUES ('SERPRO_API_URL', 'https://apigateway.serpro.gov.br'), ('SERPRO_AUTH', 'env');
ALTER TABLE votolegal_donation RENAME COLUMN procob_tested TO serpro_tested;
DROP TABLE procob_balance;
ALTER TABLE procob_result RENAME TO serpro_result;

COMMIT;
