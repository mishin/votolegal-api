-- Deploy votolegal:0044-payment-gateway to pg
-- requires: 0043-merchant

BEGIN;

create table payment_gateway (
    id   serial primary key,
    name text not null
);

insert into payment_gateway (name) values ('Cielo'), ('PagSeguro');

alter table candidate add column payment_gateway_id integer references payment_gateway(id);

COMMIT;
