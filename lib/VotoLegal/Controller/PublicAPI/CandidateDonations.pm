package VotoLegal::Controller::PublicAPI::CandidateDonations;
use common::sense;
use Moose;
use namespace::autoclean;
use DateTime;
use VotoLegal::Utils;

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

    $c->stash->{max_rows} = $ENV{MAX_DONATIONS_ROWS} || 100;

    $c->stash->{donations_rs} = $c->stash->{candidate}->votolegal_donations->search(
        {
            captured_at => { '!=' => undef },
            refunded_at => undef,
        },
        {
            columns => [
                { captured_at => \"timezone('America/Sao_Paulo', timezone('UTC', me.captured_at))" },
                { refunded_at => \"timezone('America/Sao_Paulo', timezone('UTC', me.refunded_at))" },
                { amount      => 'votolegal_donation_immutable.amount' },
                { payment_method_human => \"case when me.is_boleto then 'Boleto' else 'Cartão de crédito' end" },
                { name        => 'votolegal_donation_immutable.donor_name' },
                { cpf         => 'votolegal_donation_immutable.donor_cpf' },
                { hash        => 'me.decred_capture_txid' },
                { digest      => 'me.decred_data_digest' },
                { transaction_link => \"case when me.decred_capture_txid is not null then concat('https://explorer.dcrdata.org/tx/', me.decred_capture_txid) end" },
                { id      => 'me.id' },
                { _marker => \" extract (epoch from captured_at ) || '*' || extract (epoch from created_at )" },

            ],
            join         => 'votolegal_donation_immutable',
            order_by     => [ { '-desc' => "captured_at" }, { '-desc', 'me.created_at' } ],
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
            rows         => $c->stash->{max_rows} + 1
        }
    );

}

sub donate : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub donate_GET {
    my ( $self, $c ) = @_;

    my @donations = $c->stash->{donations_rs}->all();

    my $has_more = 0;
    if ( @donations == $c->stash->{max_rows} + 1 ) {
        $has_more++;
        pop @donations;
    }
    return $self->status_ok(
        $c,
        entity => {
            donations => \@donations,
            has_more  => $has_more ? \1 : \0,
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
        }
    );
}

sub donations_more : Chained('object') : PathPart('') : Args(1) : ActionClass('REST') { }

sub donations_more_GET {
    my ( $self, $c, $timestamps ) = @_;

    if ( $timestamps !~ /^[0-9]{10,11}(\.[0-9]{1,5})?\*[0-9]{10,11}(\.[0-9]{1,5})?$/ ) {
        $self->status_not_found( $c, message => 'invalid pagination' );
        $c->detach();
    }

    my ( $captured_at, $created_at ) = split /\*/, $timestamps;

    my $op = '<';
    my @donations = $c->stash->{donations_rs}->search(
        {
            # capture precisao de segundos, entao pode trazer os que sao iguais
            # durante o teste, preciso ignorar isso
            captured_at => { $op => \[ "to_timestamp(?)", $captured_at ] },
            created_at  => { '<' => \[ "to_timestamp(?)", $created_at ] },
        }
    )->all();

    my $has_more = 0;
    if ( @donations == $c->stash->{max_rows} + 1 ) {
        $has_more++;
        pop @donations;
    }

    return $self->status_ok(
        $c,
        entity => {
            donations => \@donations,
            has_more  => $has_more ? \1 : \0,
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()
        }
    );
}

sub donators_name : Chained('object') : PathPart('donators-name') : Args(0) : ActionClass('REST') { }

sub donators_name_GET {
    my ( $self, $c ) = @_;

    my @donations = $c->stash->{candidate}->votolegal_donations->search(
        {
            captured_at => { '!=' => undef },
            refunded_at => undef,
        },
        {
            columns  => [ { name => 'votolegal_donation_immutable.donor_name' }, ],
            join     => 'votolegal_donation_immutable',
            order_by => \'1',
            group_by => \'1',
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        }
    )->all();

    return $self->status_ok(
        $c,
        entity => {
            names        => [ map                    { $_->{name} } @donations ],
            generated_at => DateTime->now( time_zone => 'America/Sao_Paulo' )->datetime()

        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
