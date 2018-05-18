-- Deploy votolegal:0107-cer2redirect to pg
-- requires: 0106-votolegal-fp

BEGIN;

create table certiface_return_url (
    id int not null primary key,
    url varchar not null
);

insert into certiface_return_url (id, url) values (1, 'http://dev.votolegal.com.br/');

alter table certiface_token add column certiface_return_url_id int not null default 1 references certiface_return_url (id) ;
alter table certiface_token add column certiface_return_count int not null default 0;

alter table candidate add column use_certiface_return_url_id int not null default 1 references certiface_return_url (id);


COMMIT;
