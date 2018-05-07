-- Deploy votolegal:0090-deleting-offices to pg
-- requires: 0089-add-political_movement-table

BEGIN;

DELETE FROM office WHERE name IN ('Prefeito', 'Vereador', 'Vice-prefeito');

COMMIT;
