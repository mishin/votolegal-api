-- Deploy votolegal:0052-add-issue-priority to pg
-- requires: 0051-donation-address-default

BEGIN;

insert into issue_priority (name) values ('Mobilidade Urbana'), ('Democracia e Gestão Participativa');

COMMIT;
