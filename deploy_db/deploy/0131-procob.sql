-- Deploy votolegal:0131-procob to pg
-- requires: 0130-add-political-movement

BEGIN;

CREATE TABLE procob_balance (
    id         INTEGER   NOT NULL PRIMARY KEY,
    balance    TEXT      NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE procob_result (
    votolegal_donation_id uuid    REFERENCES votolegal_donation(id),
    donor_cpf             varchar NOT NULL,
    is_dead_person        BOOLEAN NOT NULL,
    response              json    NOT NULL,
    created_at            TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    updated_at            TIMESTAMP WITHOUT TIME ZONE
);

CREATE UNIQUE INDEX procob_balance_one_row
ON procob_balance((balance IS NOT NULL));

INSERT INTO procob_balance (id, balance) values (1, '100,00');

ALTER TABLE votolegal_donation ADD COLUMN procob_tested BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
