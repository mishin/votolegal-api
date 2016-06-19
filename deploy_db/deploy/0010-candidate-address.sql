-- Deploy votolegal:0010-candidate-address to pg
-- requires: 0009-cities

BEGIN;

ALTER TABLE candidate ADD COLUMN address_state TEXT NOT NULL DEFAULT '';
ALTER TABLE candidate ALTER COLUMN address_state DROP DEFAULT ;

ALTER TABLE candidate ADD COLUMN address_city TEXT NOT NULL DEFAULT '';
ALTER TABLE candidate ALTER COLUMN address_city DROP DEFAULT ;

ALTER TABLE candidate ADD COLUMN address_zipcode TEXT NOT NULL DEFAULT '';
ALTER TABLE candidate ALTER COLUMN address_zipcode DROP DEFAULT ;

ALTER TABLE candidate ADD COLUMN address_street TEXT NOT NULL DEFAULT '';
ALTER TABLE candidate ALTER COLUMN address_street DROP DEFAULT ;

ALTER TABLE candidate ADD COLUMN address_complement TEXT NOT NULL DEFAULT '';

ALTER TABLE candidate ADD COLUMN address_house_number INTEGER NOT NULL DEFAULT 123;
ALTER TABLE candidate ALTER COLUMN address_house_number DROP DEFAULT;

COMMIT;
