-- Deploy votolegal:0106-votolegal-fp to pg
-- requires: 0105-campaign_donation_type

BEGIN;

create table donation_fp (
    id bigserial not null primary key,
    fp_hash varchar,
    user_agent_id int not null references device_authorization_ua (id),
    created_at timestamp without time zone not null default now()
);

create table donation_fp_key (
    id serial not null primary key,
    "key" varchar not null,
    first_seen timestamp without time zone not null default now()
);

create table donation_fp_value (
    id serial not null primary key,
    "value" varchar not null,
    first_seen timestamp without time zone not null default now()
);

create table donation_fp_detail (
    donation_fp_id bigint not null references "donation_fp" (id),
    donation_fp_key_id int not null references "donation_fp_key" (id),
    donation_fp_value_id int not null references "donation_fp_value" (id)
);

alter table votolegal_donation add column votolegal_fp bigint references "donation_fp" (id);

COMMIT;
