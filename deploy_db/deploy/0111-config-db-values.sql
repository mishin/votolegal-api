-- Deploy votolegal:0111-config-db-values to pg
-- requires: 0110-fix-VotolegalDonation-seq

BEGIN;

create temp table confs (
 tkey varchar,
 tvalue varchar
);
insert into confs values

('EMAIL_SMTP_SERVER', '127.0.0.1'),
('EMAIL_SMTP_PORT', '443'),
('EMAIL_SMTP_USERNAME', 'username'),
('EMAIL_SMTP_PASSWORD', 'password'),
('EMAIL_DEFAULT_FROM', 'ciclano@domain.com'),
('EMAIL_CONTACT_TO', 'fulano@domain.com'),
('AMAZON_S3_ACCESS_KEY', 'token'),
('AMAZON_S3_SECRET_KEY', 'token'),
('AMAZON_S3_MEDIA_BUCKET', 'bucket-name'),
('VOTOLEGAL_PAGSEGURO_IS_SANDBOX', '1'),
('VOTOLEGAL_PAGSEGURO_MERCHANT_ID', 'token'),
('VOTOLEGAL_PAGSEGURO_MERCHANT_KEY', 'token'),
('VOTOLEGAL_PAGSEGURO_CALLBACK_URL', 'https://api.seu-votolegal.com'),
('SLACK_WEBHOOK_URL', 'https://slack-url'),
('SLACK_CHANNEL', '#channel'),
('SLACK_USERNAME', 'username'),
('SLACK_ICON_EMOJI', ':robot_face:'),
('CERTIFICATE_ENABLED', '0'),
('CERTIFACE_API_URL', 'https://api.certiface/'),
('CERTIFACE_LOGIN', 'login'),
('CERTIFACE_PASSWORD', 'password'),
('IUGU_API_URL', 'http://api.iugu.com'),
('IUGU_ACCOUNT_ID', 'token'),
('IUGU_API_KEY', 'token'),
('IUGU_API_TEST_MODE', '1'),
('MANDATOABERTO_SECURITY_TOKEN', 'token'),
('VOTOLEGAL_NO_GETH', '1'),
('VOTOLEGAL_HANGOUTS_CHAT_URL', '');

insert into "config" ( "name","value")   select tkey, tvalue from confs where tkey not in (select "name" from config where valid_to = 'infinity' );

COMMIT;
