use common::sense;

package VotoLegal::Schema::Result::ViewProjectValidVote;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewProjectValidVote');

__PACKAGE__->add_columns(qw(id candidate_id title scope votes));

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
SELECT
  project.id,
  project.candidate_id,
  project.title,
  project.scope,
  COUNT(project_vote.donation_id) AS votes
FROM project
LEFT JOIN project_vote
  ON project.id = project_vote.project_id
LEFT JOIN donation
  ON donation.id = project_vote.donation_id
  AND donation.status = 'captured'
GROUP BY project.id
SQL_QUERY
1;
