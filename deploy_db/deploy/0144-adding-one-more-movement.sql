-- Deploy votolegal:0144-adding-one-more-movement to pg
-- requires: 0143-add-testimony

BEGIN;

INSERT INTO political_movement (name) VALUES ('Triunfo');

COMMIT;
