
BEGIN;

CREATE OR REPLACE FUNCTION replaceable_now() RETURNS timestamp with time zone
    LANGUAGE sql
    AS $$
    SELECT NOW()
$$ stable;

create table device_authorization_ua (
    id serial not null primary key,
    user_agent varchar
);

create table device_authorization_token (
    id uuid not null default uuid_generate_v4() primary key,
    verified boolean not null default false,
    device_authorization_ua_id int references device_authorization_ua (id),
    device_ip inet not null,
    created_at timestamp with time zone not null
);

create table candidate_campaign_config (
    candidate_id integer primary key NOT NULL REFERENCES candidate(id),

    timezone varchar not null default 'America/Brasilia',

    pre_campaign_start date not null,
    pre_campaign_end date not null,

    campaign_start date not null,
    campaign_end date not null
);


alter table donation drop column state;

-- criando
CREATE TABLE cpf_locks (
    cpf varchar not null primary key
);

CREATE TABLE votolegal_donation (
    id uuid NOT NULL default uuid_generate_v4() primary key,
    candidate_id integer NOT NULL REFERENCES candidate(id),

    state character varying DEFAULT 'created'::character varying NOT NULL,

    created_at timestamp without time zone DEFAULT now() NOT NULL,
    captured_at timestamp without time zone,

    refunded_at timestamp without time zone,
    compensated_at timestamp without time zone,
    transferred_at timestamp without time zone,

    -- quando foi registrado na blockchain
    registered_at timestamp without time zone,
    decred_transaction_hash text,

    -- token de cartao, etc
    is_boleto bool not null,
    is_pre_campaign bool not null,
    payment_info json,

    -- detalhes da tx no gateway
    gateway_tid text,
    gateway_data json,

    -- id para usar em callback dos gateways
    callback_id uuid NOT NULL default uuid_generate_v4(),

    payment_gateway_id integer NOT NULL REFERENCES payment_gateway(id),
    certiface_token_id integer REFERENCES certiface_token (id),

    device_authorization_token_id uuid NOT NULL REFERENCES device_authorization_token(id)
);


CREATE TABLE votolegal_donation_immutable (

    votolegal_donation_id uuid primary key references votolegal_donation (id),

    donation_type_id int not null references donation_type(id),

    amount integer NOT NULL,

    donor_name text NOT NULL,
    donor_email text not null,
    donor_cpf varchar NOT NULL references "cpf_locks"(cpf),
    donor_phone text,
    donor_birthdate date not null,

    address_zipcode text,
    address_state text,
    address_city text,
    address_district text,
    address_street text,
    address_house_number integer,
    address_complement text,

    billing_address_zipcode text,
    billing_address_street text,
    billing_address_house_number integer,
    billing_address_district text,
    billing_address_city text,
    billing_address_state text,
    billing_address_complement text,

    started_ip_address inet NOT NULL
);


COMMIT;
