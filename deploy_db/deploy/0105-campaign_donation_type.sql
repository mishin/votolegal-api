-- Deploy votolegal:0105-campaign_donation_type to pg
-- requires: 0104-remove-notification-payment_id

BEGIN;

alter table candidate add column campaign_donation_type varchar not null default 'pre-campaign';

alter table candidate add constraint campaign_donation_type_is_ok check ( campaign_donation_type  in ('pre-campaign', 'campaign', 'party'));

COMMIT;
