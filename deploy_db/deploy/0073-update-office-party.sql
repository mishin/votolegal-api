-- Deploy votolegal:0073-update-office-party to pg
-- requires: 0072-donation-payment-gateway-id

BEGIN;

INSERT INTO office (name) VALUES ('Presidente'), ('Senador'), ('Governador'), ('Deputado Estadual'), ('Deputado Federal');

UPDATE party SET name = 'Avante', acronym = 'AVANTE' WHERE id = 15;
UPDATE party SET name = 'Podemos', acronym = 'PODE' WHERE id = 23;
UPDATE party SET name = 'Movimento Democrático Brasileiro', acronym = 'MDB' WHERE id = 1;

COMMIT;
