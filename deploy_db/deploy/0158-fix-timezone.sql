-- Deploy votolegal:0158-fix-timezone to pg
-- requires: 0157-julios_columns

BEGIN;

update candidate_campaign_config set timezone = 'America/Sao_Paulo';

ALTER TABLE public.candidate_campaign_config
   ALTER COLUMN timezone SET DEFAULT 'America/Sao_Paulo';
create schema if not exists utils;

create table utils.replaceable_now ( the_time timestamp with time zone );

CREATE  OR REPLACE FUNCTION replaceable_now() RETURNS timestamp with time zone AS $AA$
        SELECT coalesce((select the_time from utils.replaceable_now limit 1), now());
$AA$ LANGUAGE SQL STABLE;

/*
-- rodar em prod
drop table utils.replaceable_now;

CREATE  OR REPLACE FUNCTION replaceable_now() RETURNS timestamp with time zone AS $AA$
        SELECT now()
$AA$ LANGUAGE SQL STABLE;
*/


COMMIT;
