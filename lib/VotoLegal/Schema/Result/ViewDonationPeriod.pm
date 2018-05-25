use common::sense;

package VotoLegal::Schema::Result::ViewDonationPeriod;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewDonationPeriod');

__PACKAGE__->add_columns(qw(
    candidate_id candidate_name address_state
    days_fundraising amount_raised donation_count
    raising_goal median_per_day party)
);

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
SELECT
    s.candidate_id AS candidate_id,
    c.name AS candidate_name,
    c.address_state,
    p.name as party,
    ( c.raising_goal / 100)::numeric(20, 2) as raising_goal,
    s.count_donation_by_votolegal AS donation_count,
    date_part('day', age(current_date::timestamp, published_at::timestamp) ) + 1 AS days_fundraising,
    ( s.amount_donation_by_votolegal / 100 )::numeric(20, 2) AS amount_raised,
    ( ( s.amount_donation_by_votolegal / (date_part('day', age(current_date::timestamp, published_at::timestamp) ) + 1)::int ) / 100 )::numeric(20, 2) AS median_per_day
FROM candidate AS c, candidate_donation_summary AS s, party AS p
WHERE c.party_id = p.id AND s.candidate_id = c.id

SQL_QUERY
1;