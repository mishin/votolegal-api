-- Deploy votolegal:0120-is_published to pg
-- requires: 0119-add-new-office

BEGIN;

alter table candidate add column is_published bool not null default false;
update candidate set is_published = true where publish;

COMMIT;
