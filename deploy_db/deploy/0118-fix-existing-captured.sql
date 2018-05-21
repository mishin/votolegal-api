-- Deploy votolegal:0118-fix-existing-captured to pg
-- requires: 0117-set-timezone

BEGIN;

update votolegal_donation set captured_at = timezone( 'UTC', (payment_info->>'paid_at')::timestamp with time zone )  where captured_at is not null;

COMMIT;
