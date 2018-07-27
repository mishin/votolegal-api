-- Deploy votolegal:0161-fix-candidate_campaign_config to pg
-- requires: 0160-error_acknowledged

BEGIN;

alter table candidate_campaign_config drop column pre_campaign_julios_customer_id;
alter table candidate_campaign_config drop column campaign_julios_customer_id;

alter table candidate_campaign_config add column pre_campaign_julios_customer_id int;
alter table candidate_campaign_config add column campaign_julios_customer_id int;

COMMIT;
