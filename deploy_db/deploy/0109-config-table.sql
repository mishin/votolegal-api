-- Deploy votolegal:0109-config-table to pg
-- requires: 0108-move-ms

BEGIN;

CREATE TABLE public.config
(
  id serial NOT NULL,
  name character varying NOT NULL,
  value character varying NOT NULL,
  valid_from timestamp without time zone NOT NULL DEFAULT now(),
  valid_to timestamp without time zone NOT NULL DEFAULT 'infinity'::timestamp without time zone,
  CONSTRAINT config_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.config
  OWNER TO postgres;

CREATE UNIQUE INDEX idx_config_key
  ON public.config
  USING btree
  (name COLLATE pg_catalog."default")
  WHERE valid_to = 'infinity'::timestamp without time zone;

COMMIT;
