-- Deploy votolegal:0157-julios_columns to pg
-- requires: 0156-new-transition

BEGIN;


alter table candidate_campaign_config add column pre_campaign_boleto_split_rule_id int;
alter table candidate_campaign_config add column pre_campaign_cc_split_rule_id int;
alter table candidate_campaign_config add column pre_campaign_julios_customer_id uuid;
alter table candidate_campaign_config add column pre_campaign_julios_customer_errmsg varchar;

alter table candidate_campaign_config add column campaign_boleto_split_rule_id int;
alter table candidate_campaign_config add column campaign_cc_split_rule_id int;
alter table candidate_campaign_config add column campaign_julios_customer_id uuid;
alter table candidate_campaign_config add column campaign_julios_customer_errmsg varchar;

alter table candidate_campaign_config add column max_donation_value int not null default 106400;
alter table candidate_campaign_config add column payment_gateway_id int not null default 3;

alter table candidate_campaign_config add column campaign_is_approved bool not null default false;


alter table votolegal_donation add column julios_split_id int;



CREATE OR REPLACE FUNCTION get_config(cname varchar)
  RETURNS varchar AS
$BODY$
    SELECT "value" from config where name = cname and valid_to='infinity';
$BODY$
  LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION get_config_int(cname varchar)
  RETURNS int AS
$BODY$
    SELECT get_config(cname)::int;
$BODY$
  LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION get_config_date(cname varchar)
  RETURNS date AS
$BODY$
    SELECT get_config(cname)::date;
$BODY$
  LANGUAGE sql VOLATILE;

insert into config (name, "value")
    values ('USE_CANDIDATE_CONFIG_TABLE', '0'),

-- pre campanha
 ('CANDIDATE_CONFIG_PRE_CAMPAIGN_START_DATE', '2018-05-21'),
 ('CANDIDATE_CONFIG_PRE_CAMPAIGN_MIN_DATE', '2018-05-21'),

 ('CANDIDATE_CONFIG_PRE_CAMPAIGN_END_DATE', '2018-08-15'),
 ('CANDIDATE_CONFIG_PRE_CAMPAIGN_MAX_DATE', '2018-08-15'),

 ('CANDIDATE_CONFIG_PRE_CAMPAIGN_BOLETO_JULIOS_SPLIT_ID', '0'),
 ('CANDIDATE_CONFIG_PRE_CAMPAIGN_CC_JULIOS_SPLIT_ID', '0'),


-- campanha

 ('CANDIDATE_CONFIG_CAMPAIGN_MIN_DATE', '2018-08-15'),
 ('CANDIDATE_CONFIG_CAMPAIGN_MAX_DATE', '2018-10-07'),

 ('CANDIDATE_CONFIG_CAMPAIGN_START_DATE', '2018-05-15'),
 ('CANDIDATE_CONFIG_CAMPAIGN_END_DATE', '2018-10-07'),

 ('CANDIDATE_CONFIG_CAMPAIGN_BOLETO_JULIOS_SPLIT_ID', '0'),
 ('CANDIDATE_CONFIG_CAMPAIGN_CC_JULIOS_SPLIT_ID', '0');


CREATE OR REPLACE FUNCTION public.f_tg_candidate_add_campaign_config()
  RETURNS trigger AS
$BODY$
BEGIN

    -- se nao foi configurado, entao nao precisa fazer nada
    IF ( get_config_int('USE_CANDIDATE_CONFIG_TABLE') = 0 ) THEN

        RETURN NEW;

    END IF;


    -- se esta pago e ativo
    IF ( NEW.status = 'activated' AND NEW.payment_status = 'paid' ) THEN

        INSERT INTO public.candidate_campaign_config(
            candidate_id, pre_campaign_start, pre_campaign_end,
            campaign_start, campaign_end, pre_campaign_boleto_split_rule_id,
            pre_campaign_cc_split_rule_id,

            campaign_boleto_split_rule_id,
            campaign_cc_split_rule_id
        )
        SELECT
            NEW.id,
            get_config_date('CANDIDATE_CONFIG_PRE_CAMPAIGN_START_DATE'),
            get_config_date('CANDIDATE_CONFIG_PRE_CAMPAIGN_END_DATE'),

            get_config_date('CANDIDATE_CONFIG_CAMPAIGN_START_DATE'),
            get_config_date('CANDIDATE_CONFIG_CAMPAIGN_END_DATE'),

            get_config_int('CANDIDATE_CONFIG_PRE_CAMPAIGN_BOLETO_JULIOS_SPLIT_ID'),
            get_config_int('CANDIDATE_CONFIG_PRE_CAMPAIGN_CC_JULIOS_SPLIT_ID'),

            get_config_int('CANDIDATE_CONFIG_CAMPAIGN_BOLETO_JULIOS_SPLIT_ID'),
            get_config_int('CANDIDATE_CONFIG_CAMPAIGN_CC_JULIOS_SPLIT_ID')

        WHERE NOT EXISTS (
            SELECT 1
            FROM candidate_campaign_config
            WHERE candidate_id = NEW.id
        );

    END IF;


    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER t_candidate_add_campaign_config
  AFTER INSERT OR UPDATE
  ON public.candidate
  FOR EACH ROW
  EXECUTE PROCEDURE f_tg_candidate_add_campaign_config();


COMMIT;
