-- Deploy votolegal:0094-adding-more-options-movement to pg
-- requires: 0093-fix-refund-logic

BEGIN;

INSERT INTO political_movement (name) VALUES ('Não participo de um movimento'), ('Participo de um movimento não listado');

COMMIT;
