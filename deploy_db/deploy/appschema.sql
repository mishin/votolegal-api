-- Deploy votolegal:appschema to pg

BEGIN;

CREATE TABLE "user"
(
  id         SERIAL PRIMARY KEY,
  username   text UNIQUE,
  password   text,
  email      text NOT NULL UNIQUE,
  created_at timestamp with time zone NOT NULL DEFAULT now()
) ;

CREATE TABLE role (
    id   INTEGER PRIMARY KEY,
    name TEXT
);

INSERT INTO role VALUES (1, 'admin');
INSERT INTO role VALUES (2, 'user');

CREATE TABLE user_role (
    user_id INTEGER REFERENCES "user"(id),
    role_id INTEGER REFERENCES role(id),
    CONSTRAINT user_role_pkey PRIMARY KEY (user_id, role_id)
);

CREATE TABLE public.user_session
(
  id SERIAL PRIMARY KEY,
  user_id integer NOT NULL REFERENCES "user"(id),
  api_key text NOT NULL UNIQUE,
  valid_for_ip text,
  created_at timestamp without time zone NOT NULL DEFAULT now()
);

INSERT INTO "user" (username, password, email) VALUES ('admin', 'reBXSBHPrtEoRrH2GtJVye6w780FGABokqbBEQb0N0xvgAclgstba', 'juniorfvox@gmail.com') ;
INSERT INTO user_roles (role_id, user_id) VALUES (1, 1) ;

COMMIT;
