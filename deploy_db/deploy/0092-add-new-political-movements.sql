-- Deploy votolegal:0092-add-new-political-movements to pg
-- requires: 0091-adding-candidate-birth_date

BEGIN;

UPDATE political_movement SET name = 'RenovaBR' WHERE name = 'Renova';
INSERT INTO political_movement (name) VALUES ('Muitxs'), ('Bancada Ativista');

COMMIT;
