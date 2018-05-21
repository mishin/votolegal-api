-- Deploy votolegal:0115-donation-decred to pg
-- requires: 0114-candidate_donation_summary

BEGIN;

ALTER TABLE votolegal_donation ADD COLUMN decred_merkle_root TEXT;
ALTER TABLE votolegal_donation ADD COLUMN decred_merkle_registered_at TIMESTAMP WITHOUT TIME ZONE;
ALTER TABLE votolegal_donation ADD COLUMN decred_data_raw TEXT;
ALTER TABLE votolegal_donation ADD COLUMN decred_data_hash TEXT;
ALTER TABLE votolegal_donation RENAME COLUMN decred_data_hash TO decred_data_digest;

ALTER TABLE votolegal_donation_immutable ADD COLUMN git_hash TEXT;

DROP TRIGGER tg_votolegal_donation_immutable_delete ON public.votolegal_donation_immutable;
DROP TRIGGER tg_votolegal_donation_immutable_update ON public.votolegal_donation_immutable;

UPDATE votolegal_donation_immutable SET git_hash = '(null)';

ALTER TABLE votolegal_donation_immutable ADD COLUMN git_hash SET NOT NULL;

ALTER TABLE votolegal_donation RENAME COLUMN decred_capture_hash TO decred_capture_txid;

CREATE TRIGGER tg_votolegal_donation_immutable_delete
  BEFORE DELETE
  ON public.votolegal_donation_immutable
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tg_votolegal_donation_immutable();

CREATE TRIGGER tg_votolegal_donation_immutable_update
  BEFORE UPDATE
  ON public.votolegal_donation_immutable
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tg_votolegal_donation_immutable();


COMMIT;
