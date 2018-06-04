-- Deploy votolegal:0130-add-political-movement to pg
-- requires: 0129-next-gateway-check

BEGIN;

INSERT INTO political_movement (name) VALUES ('Acredito');

COMMIT;
