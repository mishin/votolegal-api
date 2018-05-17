-- Deploy votolegal:0103-really-_immutable to pg
-- requires: 0102-DeviceAuthorizationToken

BEGIN;

CREATE OR REPLACE FUNCTION f_tg_votolegal_donation_immutable()
  RETURNS TRIGGER AS
$BODY$
BEGIN
    RAISE EXCEPTION 'this table cannot be updated';

    RETURN NEW;
END;
$BODY$ LANGUAGE PLPGSQL;


CREATE TRIGGER tg_votolegal_donation_immutable_update
BEFORE UPDATE
  ON votolegal_donation_immutable
FOR EACH ROW
EXECUTE PROCEDURE f_tg_votolegal_donation_immutable();

CREATE TRIGGER tg_votolegal_donation_immutable_delete
BEFORE DELETE
  ON votolegal_donation_immutable
FOR EACH ROW
EXECUTE PROCEDURE f_tg_votolegal_donation_immutable();


alter table votolegal_donation drop column registered_at;
alter table votolegal_donation drop column decred_transaction_hash;

alter table votolegal_donation add column decred_capture_registered_at timestamp without time zone;
alter table votolegal_donation add column decred_capture_hash varchar;

alter table votolegal_donation add column decred_refund_registered_at  timestamp without time zone;
alter table votolegal_donation add column decred_refund_hash varchar;

COMMIT;
