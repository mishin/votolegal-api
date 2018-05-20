package VotoLegal::Controller::PublicAPI::CandidateDonations;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/publicapi/root') : PathPart('candidate-donations') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::Candidate')->search( { status => 'activated' } );
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

sub donate : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub donate_GET {
    my ( $self, $c ) = @_;

    my @donations = $c->stash->{candidate}->votolegal_donations->search(
        {
            captured_at => { '!=' => undef },
            refunded_at => undef,
        },
        {
            columns => [
                { captured_at => \" timezone('America/Sao_Paulo', timezone('UTC', me.captured_at))" },
                { amount      => 'votolegal_donation_immutable.amount' },
                { name        => 'votolegal_donation_immutable.donor_name' },
                { cpf         => 'votolegal_donation_immutable.donor_cpf' },
                { hash        => 'me.decred_capture_hash' }
            ],
            join         => 'votolegal_donation_immutable',
            order_by     => [ { '-desc' => "captured_at" }, 'me.id' ],
            page         => 1,
            rows         => 100,
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all();

    return $self->status_ok(
        $c,
        entity => {
            donations => \@donations,
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
