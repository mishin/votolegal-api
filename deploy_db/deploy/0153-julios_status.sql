-- Deploy votolegal:0153-julios_status to pg
-- requires: 0152-add-has_custom_site

BEGIN;

alter table votolegal_donation add column julios_status varchar;
alter table votolegal_donation add column julios_updated_at timestamp without time zone;

COMMIT;
