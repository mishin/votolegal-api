use common::sense;

package VotoLegal::Schema::Result::ViewDonationPeriod;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewDonationPeriod');

__PACKAGE__->add_columns(qw(
    candidate_id candidate_name address_state
    days_fundraising amount_raised donation_count
    raising_goal median_per_day party avg_donation_amount
    goal_raised_percentage amount_boleto amount_credit_card
    count_credit_card count_boleto)
);

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
SELECT
    s.candidate_id AS candidate_id,
    c.name AS candidate_name,
    c.address_state,
    p.name as party,
    ( c.raising_goal )::float8::numeric(11, 2) as raising_goal,
    s.count_donation_by_votolegal AS donation_count,
    date_part('day', age(current_date::timestamp, published_at::timestamp) ) + 1 AS days_fundraising,
    ( s.amount_donation_by_votolegal / 100 )::float8::numeric(11, 0) AS amount_raised,
    ( ( s.amount_donation_by_votolegal / (date_part('day', age(current_date::timestamp, published_at::timestamp) ) + 1)::int ) / 100 )::float8::numeric AS median_per_day,
    ( CASE s.count_donation_by_votolegal
        WHEN 0 THEN 0
        ELSE ( ( s.amount_donation_by_votolegal / s.count_donation_by_votolegal ) / 100 )::float8::numeric(11, 0)
        END
    ) as avg_donation_amount,
    ( ( ( s.amount_donation_by_votolegal / 100 ) / c.raising_goal ) * 100 )::numeric(11, 3) as goal_raised_percentage,
    ( select sum(amount) from votolegal_donation_immutable i, votolegal_donation d where d.is_boleto = true and d.captured_at is not null and d.id = i.votolegal_donation_id and d.candidate_id = c.id  and d.refunded_at is null) / 100 as amount_boleto,
    ( select count(1) from votolegal_donation where is_boleto = false and captured_at is not null and refunded_at is null and candidate_id = c.id) as count_credit_card,
    ( select sum(amount) from votolegal_donation_immutable i, votolegal_donation d where d.is_boleto = false and d.captured_at is not null and d.id = i.votolegal_donation_id and d.candidate_id = c.id and d.refunded_at is null ) / 100 as amount_credit_card,
	( select count(1) from votolegal_donation where is_boleto = true and captured_at is not null and refunded_at is null and candidate_id = c.id) as count_boleto
FROM candidate AS c, candidate_donation_summary AS s, party AS p
WHERE c.party_id = p.id AND s.candidate_id = c.id AND c.is_published = true
    AND c.name NOT ILIKE '%Edgard%' AND c.name NOT ILIKE '%Lucas Ansei%'
    AND c.name NOT ILIKE '%demais%'
SQL_QUERY
1;