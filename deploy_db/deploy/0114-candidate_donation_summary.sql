-- Deploy votolegal:0114-candidate_donation_summary to pg
-- requires: 0113-min-donation

BEGIN;


create table candidate_donation_summary (
    candidate_id int primary key not null references candidate (id),

    amount_donation_by_votolegal bigint not null default 0,
    count_donation_by_votolegal int not null default 0,

    amount_donation_beside_votolegal bigint not null default 0,
    count_donation_beside_votolegal int not null default 0,

    amount_refunded bigint not null default 0,
    count_refunded int not null default 0
);

insert into candidate_donation_summary(candidate_id)
select id from candidate;

CREATE OR REPLACE FUNCTION public.f_tg_add_candidate_donation_summary()
  RETURNS trigger AS
$BODY$
BEGIN

    insert into candidate_donation_summary (candidate_id) values (NEW.id);

    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE TRIGGER tg_add_candidate_donation_summary_isrt
  AFTER INSERT
  ON public.candidate
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tg_add_candidate_donation_summary();


COMMIT;
