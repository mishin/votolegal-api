-- Deploy votolegal:0080-add-payment_gateway to pg
-- requires: 0079-adding-certiface

BEGIN;

INSERT INTO payment_gateway (name) VALUES ('Iugu');

COMMIT;
