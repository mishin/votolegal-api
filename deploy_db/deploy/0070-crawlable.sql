-- Deploy votolegal:0070-crawlable to pg
-- requires: 0069-by-votolegal-nn

BEGIN;

alter table candidate add column crawlable boolean not null default 'true' ;

COMMIT;
