-- Deploy votolegal:0121-view-donations to pg
-- requires: 0120-is_published

BEGIN;

create schema reports;

create or replace view reports.donations_our as
select
    me.*,
    b.*,
    c.name as candidate_name
from votolegal_donation me
join votolegal_donation_immutable  b on b.votolegal_donation_id = me.id
join candidate c on c.id = me.candidate_id left join donation_fp fp on fp.id = votolegal_fp
order by me.created_at desc;


create or replace view reports.donations_simple as

with
donation_fp_view as ( select fp_hash, user_agent_id , count(1) as pc from donation_fp group by 1,2 ),
donation_cc_view as ( select (stash->>'cc_hash') as cc_hash, b.donor_cpf, count(1) as cc from votolegal_donation a join votolegal_donation_immutable b on b.votolegal_donation_id = a.id where is_boleto = false group by 1,2 )

select

case
    when captured_at is not null        then 'Cartão capturado em ' || me.captured_at::text
    when state     = 'not_authorized'   then 'Cartão não autorizado'
    when state     = 'credit_card_form' then 'Falta cartão'
 else state end as status,
 'R$ ' || (b.amount / 100)::numeric(9,2) as valor,
 b.donor_cpf,
 b.donor_name,
 c.name as candidate_name,
 fpv.pc as donations_in_same_fingerprint,
 fp.id as fp_id,
 me.id as donation_id,
 dcv.cc as donations_in_same_cc_diff_cpf

from votolegal_donation me
join votolegal_donation_immutable  b on b.votolegal_donation_id = me.id
join candidate c on c.id = me.candidate_id left join donation_fp fp on fp.id = votolegal_fp
left join donation_fp_view fpv on fpv.fp_hash = fp.fp_hash and fpv.user_agent_id = fp.user_agent_id
left join donation_cc_view dcv on me.is_boleto = false AND dcv.cc_hash = (stash->>'cc_hash') and dcv.donor_cpf != b.donor_cpf

order by me.created_at desc;


COMMIT;
