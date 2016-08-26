-- Deploy votolegal:0060-donation-crawl to pg
-- requires: 0059-party-fund

BEGIN;

alter table donation alter column email drop not null;
alter table donation alter column birthdate drop not null;
alter table donation alter column address_state drop not null;
alter table donation alter column address_city drop not null;
alter table donation alter column address_zipcode drop not null;
alter table donation alter column address_street drop not null;
alter table donation alter column address_house_number drop not null;
alter table donation alter column billing_address_street drop not null;
alter table donation alter column billing_address_house_number drop not null;
alter table donation alter column billing_address_district drop not null;
alter table donation alter column billing_address_zipcode drop not null;
alter table donation alter column billing_address_city drop not null;
alter table donation alter column billing_address_state drop not null;
alter table donation alter column address_district drop not null;

COMMIT;
