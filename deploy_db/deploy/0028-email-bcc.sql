-- Deploy votolegal:0028-email-bcc to pg
-- requires: 0027-ficha-limpa

BEGIN;

ALTER TABLE email_queue ADD COLUMN bcc text[] ;

COMMIT;
