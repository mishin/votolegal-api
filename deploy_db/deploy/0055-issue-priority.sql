-- Deploy votolegal:0055-issue-priority to pg
-- requires: 0054-donation-paid-at

BEGIN;

insert into issue_priority (name) values ('Turismo'), ('Empreendedorismo');

COMMIT;
