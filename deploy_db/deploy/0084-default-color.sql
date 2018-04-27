-- Deploy votolegal:0084-default-color to pg
-- requires: 0083-candidate-mandatoaberto-integration

BEGIN;

UPDATE candidate SET color = 'default';
ALTER TABLE candidate ALTER COLUMN color SET DEFAULT 'default';

COMMIT;
