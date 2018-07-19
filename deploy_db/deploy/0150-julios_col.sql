-- Deploy votolegal:0150-julios_col to pg
-- requires: 0149-add-env

BEGIN;

alter table votolegal_donation add column julios_next_check timestamp without time zone;
alter table votolegal_donation add column julios_erromsg varchar;

update votolegal_donation set julios_next_check=now() where captured_at is not null ;


COMMIT;
