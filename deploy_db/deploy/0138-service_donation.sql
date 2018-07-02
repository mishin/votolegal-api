-- Deploy votolegal:0138-service_donation to pg
-- requires: 0137-certiface-per-candidate

BEGIN;

CREATE TABLE candidate_service_donation (
    id                 SERIAL    PRIMARY KEY,
    candidate_id       INTEGER   REFERENCES candidate(id) NOT NULL,
    equivalent_amount  INTEGER   NOT NULL,
    name               TEXT      NOT NULL,
    vacancies          INTEGER   NOT NULL,
    desciption         TEXT      NOT NULL,
    procedure          TEXT      NOT NULL,
    address_state      TEXT      NOT NULL,
    address_city       TEXT      NOT NULL,
    address_zipcode    TEXT      NOT NULL,
    address_district   TEXT      NOT NULL,
    address_street     TEXT      NOT NULL,
    address_number     INTEGER   NOT NULL,
    address_complement TEXT,
    execution_at       TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    execution_until    TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    inscription_limit  TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    created_at         TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE candidate_service_donor (
    id                 SERIAL PRIMARY KEY,
    email              TEXT   NOT NULL UNIQUE,
    cpf                TEXT   UNIQUE,
    name               TEXT,
    phone              TEXT,
    address_country    TEXT,
    address_state      TEXT,
    address_city       TEXT,
    address_zipcode    TEXT,
    address_district   TEXT,
    address_street     TEXT,
    address_number     INTEGER,
    address_complement TEXT,
    created_at         TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE candidate_service_donation_inscription (
    id                            SERIAL NOT NULL,
    validation_token              TEXT    NOT NULL,
    candidate_service_donation_id INTEGER NOT NULL REFERENCES candidate_service_donation(id),
    candidate_service_donor_id    INTEGER NOT NULL REFERENCES candidate_service_donor(id),
    created_at                    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    candidate_refused_at          TIMESTAMP WITHOUT TIME ZONE,
    candidate_accepted_at         TIMESTAMP WITHOUT TIME ZONE,
    donor_accepted_at             TIMESTAMP WITHOUT TIME ZONE
);

COMMIT;
