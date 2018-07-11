-- Deploy votolegal:0142-add-jenkins_auth-env to pg
-- requires: 0141-sender_hash-set-not-null

BEGIN;

INSERT INTO config (name, value) VALUES ('JENKINS_AUTH', 'env');

COMMIT;
