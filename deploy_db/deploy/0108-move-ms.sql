-- Deploy votolegal:0108-move-ms to pg
-- requires: 0107-cer2redirect

BEGIN;

alter table donation_fp add column ms int;

alter table donation_fp add column canvas_result bigint;
alter table donation_fp add column webgl_result bigint;

COMMIT;
