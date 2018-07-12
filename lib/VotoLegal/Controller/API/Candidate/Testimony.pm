package VotoLegal::Controller::API::Candidate::Testimony;
use common::sense;
use Moose;
use namespace::autoclean;

use VotoLegal::Uploader;

use File::MimeInfo;
use Crypt::PRNG qw(random_string);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::TypesValidation';
with "CatalystX::Eta::Controller::AutoResultPUT";

has uploader => (
	is      => "ro",
	isa     => "VotoLegal::Uploader",
	default => sub { VotoLegal::Uploader->new() },
);

__PACKAGE__->config(
    # AutoResultPUT.
	object_key                => "testimony",
	result_put_for            => "update",
    prepare_params_for_update => sub {
        my ($self, $c, $params) = @_;

		my $picture;
		if ( my $upload = $c->req->upload("reviewer_picture") ) {

			$picture = $self->_upload_picture($upload);
            $params->{reviewer_picture} = $picture->{url};
		}

        return $params;
    }
);

sub root : Chained('/api/candidate/object') : PathPart('') : CaptureArgs(0) {
	my ( $self, $c ) = @_;

	$c->stash->{collection} = $c->model('DB::Testimony');
}

sub base : Chained('root') : PathPart('testimony') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $testimony_id ) = @_;

    $c->stash->{collection} = $c->stash->{collection}->search( { id => $testimony_id } );

    my $testimony = $c->stash->{collection}->find($testimony_id);
    $c->detach("/error_404") unless ref $testimony;

	$c->stash->{is_me}     = int( $c->user->id == $testimony->candidate->user->id );
	$c->stash->{testimony} = $testimony;
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
	my ( $self, $c ) = @_;

	my $picture;
	if ( my $upload = $c->req->upload("reviewer_picture") ) {

		$picture = $self->_upload_picture($upload);
	}

    my $testimony = $c->stash->{collection}->execute(
        $c,
        for  => 'create',
        with => {
            %{ $c->req->params },
            reviewer_picture => $picture->{url},
            candidate_id     => $c->stash->{candidate}->id
        }
    );

    return $self->status_created(
        $c,
		location => $c->uri_for_action( $c->action, $c->req->captures, $testimony->id )->as_string,
        entity   => { id => $testimony->id }
    );
}

sub list_GET {
    my ( $self, $c ) = @_;

    return $self->status_ok(
        $c,
        entity => {
            testimonies => [
                map {
                    my $t = $_;

                    +{
                        id               => $t->id,
                        reviewer_name    => $t->reviewer_name,
                        reviewer_picture => $t->reviewer_picture,
                        reviewer_text    => $t->reviewer_text,
                    }
                } $c->stash->{collection}->search(
                    {
                        candidate_id => $c->stash->{candidate}->id,
                        active       => 1
                    }
                  )->all()
            ]
        }
    );
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

    $c->detach("/api/forbidden") unless $c->stash->{is_me};
}

sub result_PUT { }

sub _upload_picture {
	my ( $self, $upload ) = @_;

	my $mimetype = mimetype( $upload->tempname );
	my $tempname = $upload->tempname;

	die \[ 'picture', 'empty file' ]    unless $upload->size > 0;
	die \[ 'picture', 'invalid image' ] unless $mimetype =~ m{^image\/};

	my $path = join "/", "votolegal", "picture", random_string(3), DateTime->now->epoch, $tempname;

	my $url = $self->uploader->upload(
		{
			path => $path,
			file => $tempname,
			type => $mimetype,
		}
	);

	return {
		url => $url->as_string,
	};
}

__PACKAGE__->meta->make_immutable;

1;
