-- Deploy votolegal:0042-new-issue-priorities to pg
-- requires: 0041-donation-ip

BEGIN;

insert into issue_priority (name) VALUES ('Mobilidade Urbana'), ('Democracia e Gestão Participativa'), ('Política sobre drogas') ;

COMMIT;
