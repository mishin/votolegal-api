package VotoLegal::Controller::PublicAPI::CandidateSummary;
use common::sense;
use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/publicapi/root') : PathPart('candidate-summary') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate')->search(
        {
            status  => 'activated',
            is_published => 1
        },
        {
            '+columns' => {
                address_state_name            => \'(select name from state x where x.code = me.address_state limit 1)',
                has_mandatoaberto_integration => \
                  'EXISTS (select 1 from candidate_mandato_aberto_integration x where x.candidate_id = me.id)'
            },
            prefetch =>
              [ 'party', 'candidate_donation_summary', { 'candidate_issue_priorities' => 'issue_priority' }, ],
        },
    );
}

sub base : Chained('root') : PathPart('') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $args ) = @_;

    # Quando o parâmetro é inteiramente numérico, o buscamos como id.
    # Quando não é, pesquisamos pelo 'slug'.
    my $candidate;
    if ( $args =~ m{^[0-9]{1,6}$} ) {
        $candidate = $c->stash->{collection}->find($args);
    }
    else {
        $candidate = $c->stash->{collection}->search( { 'me.username' => $args } )->next;
    }

    if ( !$candidate ) {
        $self->status_not_found( $c, message => 'Candidate not found' );
        $c->detach();
    }

    $c->stash->{candidate} = $candidate;
}

sub candidate : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub candidate_GET {
    my ( $self, $c ) = @_;

    my $candidate = {
        party                      => { $c->stash->{candidate}->party->get_columns() },
        candidate_issue_priorities => [
            map {
                { $_->issue_priority->get_columns() }
            } $c->stash->{candidate}->candidate_issue_priorities->all
        ],
        max_donation_value => 106400
    };

    $candidate = {
        %{$candidate},
        map { $_ => $c->stash->{candidate}->get_column($_) }
          qw(
          id name popular_name status reelection party_id office_id status username picture color publish
          video_url facebook_url twitter_url website_url summary biography instagram_url cnpj cpf
          raising_goal public_email spending_spreadsheet address_city address_state address_state_name
          political_movement_id google_analytics collect_donor_phone collect_donor_address
          min_donation_value
          )
    };

    # fix para ficar igual os oturos valores
    if ( $candidate->{raising_goal} ) {
        $candidate->{raising_goal} *= 100;
    }
    else {
        $candidate->{raising_goal} = 100000;
    }

    $candidate->{party_fund}                 = $c->stash->{candidate}->party_fund();
    $candidate->{total_donated}              = $c->stash->{candidate}->total_donated();
    $candidate->{total_donated_by_votolegal} = $c->stash->{candidate}->total_donated_by_votolegal();
    $candidate->{people_donated}             = $c->stash->{candidate}->people_donated();

    # nao sei o que eh isso, acho que nao aparece mais na tela
    # $candidate->{signed_contract}               = $c->stash->{candidate}->user->has_signed_contract();
    $candidate->{has_mandatoaberto_integration} = $c->stash->{candidate}->get_column('has_mandatoaberto_integration');

    $candidate->{projects} = [
        map {
            { $_->get_columns }
          } $c->model('DB::ViewProjectValidVote')->search(
            { candidate_id => $c->stash->{candidate}->id },
            {
                rows     => 20,
                order_by => "votes",
            }
          )->all
    ];

    $candidate->{political_movement_name} = $c->stash->{candidate}->political_movement_id ? $c->stash->{candidate}->political_movement->name : ();

    return $self->status_ok(
        $c,
        entity => {
            candidate => $candidate,
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
