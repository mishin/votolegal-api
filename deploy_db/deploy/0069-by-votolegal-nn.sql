-- Deploy votolegal:0069-by-votolegal-nn to pg
-- requires: 0068-no-party-fund

BEGIN;

alter table donation alter column by_votolegal set not null ;

COMMIT;
