-- Deploy votolegal:0089-add-political_movement-table to pg
-- requires: 0088-payment-cpf

BEGIN;

CREATE TABLE political_movement(
    id   SERIAL PRIMARY KEY,
    name TEXT   NOT NULL
);
INSERT INTO political_movement (name) VALUES ('Renova'), ('Nós'), ('Agora');
ALTER TABLE candidate ADD COLUMN political_movement_id INTEGER REFERENCES political_movement(id);

COMMIT;
