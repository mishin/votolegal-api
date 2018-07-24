use common::sense;

package VotoLegal::Schema::Result::ViewOpenDonationsWith3DayPeriod;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewOpenDonationsWith3DayPeriod');

__PACKAGE__->add_columns(qw(id candidate_id state donor_email donor_name created_at));

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
WITH open_donations AS (
    SELECT d.id, d.candidate_id, d.state, i.donor_email, i.donor_cpf, d.created_at, i.donor_name
        FROM votolegal_donation AS d, votolegal_donation_immutable AS i, candidate AS c
        WHERE d.created_at BETWEEN ( now()::date - interval '3 days' ) AND ( now()::date - interval '2 days' )
            AND state IN ('credit_card_form', 'boleto_authetication')
            AND d.id = i.votolegal_donation_id
            AND d.candidate_id = c.id
            AND c.emaildb_config_id = 2
)
SELECT o.id,
       o.candidate_id,
       o.state,
       o.donor_email,
       o.donor_name,
       o.created_at
    FROM open_donations AS o
    WHERE NOT EXISTS (
        SELECT 1 FROM votolegal_donation_immutable, votolegal_donation
            WHERE
                votolegal_donation_immutable.donor_cpf = o.donor_cpf
                AND votolegal_donation.created_at >= now()::date - interval '3 days'
                AND votolegal_donation.id = votolegal_donation_immutable.votolegal_donation_id
                AND votolegal_donation.captured_at IS NOT NULL
    )
SQL_QUERY
1;
