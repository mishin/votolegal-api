-- Deploy votolegal:0090-deleting-offices to pg
-- requires: 0089-add-political_movement-table

BEGIN;

UPDATE candidate SET office_id = 4;
DELETE FROM office WHERE name IN ('Prefeito', 'Vereador', 'Vice-prefeito');

COMMIT;
