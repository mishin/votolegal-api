-- Deploy votolegal:0029-issue-priorities-prod to pg
-- requires: 0028-email-bcc

BEGIN;

TRUNCATE issue_priority RESTART IDENTITY CASCADE;

INSERT INTO issue_priority (name) VALUES ('Saúde'), ('Educação'), ('Meio Ambiente'), ('Turismo'), ('Economia'), ('Segurança'), ('Emprego'), ('Tecnologia'), ('Alimentação'), ('Bem estar animal'), ('Agropecuária'), ('Transporte Público'), ('Infraestrutura'), ('Aposentadoria'), ('Bolsa de Estudos'), ('Urbanização') ;

COMMIT;
