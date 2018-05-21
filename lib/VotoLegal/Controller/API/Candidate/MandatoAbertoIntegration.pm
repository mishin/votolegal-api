package VotoLegal::Controller::API::Candidate::MandatoAbertoIntegration;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/candidate/base') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model("DB::CandidateMandatoAbertoIntegration");
}

sub base : Chained('root') : PathPart('mandatoaberto_integration') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ( $self, $c ) = @_;

    my $security_token = $c->req->params->{security_token};
    die \[ 'security_token', 'missing' ] unless $security_token;
    die \[ 'security_token', 'invalid' ] unless $security_token eq $ENV{MANDATOABERTO_SECURITY_TOKEN};

    my $email = $c->req->params->{email};
    die \[ 'email', 'missing' ] unless $email;

    my $candidate_user = $c->model("DB::User")->search( { email => $email } )->next;
    die \[ 'email', 'could not find user with that email' ] unless $candidate_user;

    my $candidate = $candidate_user->candidates->search()->next;
    die \[ 'email', 'user is not a candidate' ] unless $candidate;

    my $mandatoaberto_id = $c->req->params->{mandatoaberto_id};
    die \[ 'mandatoaberto_id', 'missing' ] unless $mandatoaberto_id;

    my $mandatoaberto_integration = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => {
            candidate_id     => $candidate->id,
            mandatoaberto_id => $mandatoaberto_id
        }
    );

    return $self->status_ok(
        $c,
        entity => {
            id       => $candidate->id,
            username => $candidate->username
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
