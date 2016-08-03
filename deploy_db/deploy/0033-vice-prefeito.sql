-- Deploy votolegal:0033-vice-prefeito to pg
-- requires: 0032-payment-status

BEGIN;

INSERT INTO office (name) VALUES ('Vice-prefeito') ;

COMMIT;
