-- Deploy votolegal:0123-audit-tables to pg
-- requires: 0122-donor_birthdate_can-be-null

BEGIN;

create schema audit;


CREATE TABLE audit.candidate_history
(
  id bigserial NOT NULL,
  data json NOT NULL,
  op text NOT NULL,
  op_ts timestamp without time zone DEFAULT now(),
  candidate_id int NOT NULL,
  CONSTRAINT candidate_history_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE OR REPLACE FUNCTION audit.candidate_history_func()
  RETURNS trigger AS
$BODY$
DECLARE
    old_data json;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        old_data := row_to_json(OLD.*);
        INSERT INTO audit.candidate_history (candidate_id, data, op) VALUES (OLD.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        old_data := row_to_json(NEW.*);

        INSERT INTO audit.candidate_history (candidate_id, data, op) VALUES (NEW.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100;

CREATE TRIGGER t_candidate_history
  AFTER INSERT OR UPDATE
  ON public."candidate"
  FOR EACH ROW
  EXECUTE PROCEDURE audit.candidate_history_func();



CREATE TABLE audit.candidate_campaign_config_history
(
  id bigserial NOT NULL,
  data json NOT NULL,
  op text NOT NULL,
  op_ts timestamp without time zone DEFAULT now(),
  candidate_id int NOT NULL,
  CONSTRAINT candidate_campaign_config_history_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE OR REPLACE FUNCTION audit.candidate_campaign_config_history_func()
  RETURNS trigger AS
$BODY$
DECLARE
    old_data json;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        old_data := row_to_json(OLD.*);
        INSERT INTO audit.candidate_campaign_config_history (candidate_id, data, op) VALUES (OLD.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        old_data := row_to_json(NEW.*);

        INSERT INTO audit.candidate_campaign_config_history (candidate_id, data, op) VALUES (NEW.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100;

CREATE TRIGGER t_candidate_campaign_config_history
  AFTER INSERT OR UPDATE
  ON public."candidate_campaign_config"
  FOR EACH ROW
  EXECUTE PROCEDURE audit.candidate_campaign_config_history_func();


CREATE TABLE audit.votolegal_donation_history
(
  id bigserial NOT NULL,
  data json NOT NULL,
  op text NOT NULL,
  op_ts timestamp without time zone DEFAULT now(),
  votolegal_donation_id uuid NOT NULL,
  CONSTRAINT votolegal_donation_history_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE OR REPLACE FUNCTION audit.votolegal_donation_history_func()
  RETURNS trigger AS
$BODY$
DECLARE
    old_data json;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        old_data := row_to_json(OLD.*);
        INSERT INTO audit.votolegal_donation_history (votolegal_donation_id, data, op) VALUES (OLD.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        old_data := row_to_json(NEW.*);

        INSERT INTO audit.votolegal_donation_history (votolegal_donation_id, data, op) VALUES (NEW.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100;

CREATE TRIGGER t_votolegal_donation_history
  AFTER INSERT OR UPDATE
  ON public."votolegal_donation"
  FOR EACH ROW
  EXECUTE PROCEDURE audit.votolegal_donation_history_func();





CREATE TABLE audit.project_history
(
  id bigserial NOT NULL,
  data json NOT NULL,
  op text NOT NULL,
  op_ts timestamp without time zone DEFAULT now(),
  project_id int NOT NULL,
  CONSTRAINT project_history_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE OR REPLACE FUNCTION audit.project_history_func()
  RETURNS trigger AS
$BODY$
DECLARE
    old_data json;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        old_data := row_to_json(OLD.*);
        INSERT INTO audit.project_history (project_id, data, op) VALUES (OLD.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        old_data := row_to_json(NEW.*);

        INSERT INTO audit.project_history (project_id, data, op) VALUES (NEW.id, old_data, substring(TG_OP, 1, 1));

        RETURN NEW;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100;

CREATE TRIGGER t_project_history
  AFTER INSERT OR UPDATE
  ON public."project"
  FOR EACH ROW
  EXECUTE PROCEDURE audit.project_history_func();
COMMIT;
