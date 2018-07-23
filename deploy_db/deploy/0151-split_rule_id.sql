-- Deploy votolegal:0151-split_rule_id to pg
-- requires: 0150-julios_col

BEGIN;

alter table candidate add column split_rule_id int;
alter table candidate add column julios_customer_id int;


COMMIT;
