-- Deploy votolegal:0137-certiface-per-candidate to pg
-- requires: 0136-add-avatar

BEGIN;

alter table candidate add column use_certiface boolean not null default true;


COMMIT;
