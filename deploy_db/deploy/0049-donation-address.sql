-- Deploy votolegal:0049-donation-address to pg
-- requires: 0048-candidate-bank

BEGIN;

ALTER TABLE donation ADD COLUMN address_state TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN address_state DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN address_city TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN address_city DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN address_zipcode TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN address_zipcode DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN address_street TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN address_street DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN address_complement TEXT NOT NULL DEFAULT '';

ALTER TABLE donation ADD COLUMN address_house_number INTEGER NOT NULL DEFAULT 1;
ALTER TABLE donation ALTER COLUMN address_house_number DROP DEFAULT;

ALTER TABLE donation ADD COLUMN billing_address_street TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN billing_address_street DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN billing_address_house_number INTEGER NOT NULL DEFAULT 1;
ALTER TABLE donation ALTER COLUMN billing_address_house_number DROP DEFAULT;

ALTER TABLE donation ADD COLUMN billing_address_district TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN billing_address_district DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN billing_address_zipcode TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN billing_address_zipcode DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN billing_address_city TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN billing_address_city DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN billing_address_state TEXT NOT NULL DEFAULT '';
ALTER TABLE donation ALTER COLUMN billing_address_state DROP DEFAULT ;

ALTER TABLE donation ADD COLUMN billing_address_complement TEXT NOT NULL DEFAULT '';

COMMIT;
