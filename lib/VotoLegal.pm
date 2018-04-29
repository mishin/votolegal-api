package VotoLegal;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use Catalyst qw/
  ConfigLoader

  Authentication
  Authorization::Roles
  /;

BEGIN { $ENV{$_} or die "missing env '$_'." for qw/ RECAPTCHA_PUBKEY RECAPTCHA_PRIVKEY / }

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name     => 'VotoLegal',
    encoding => 'UTF-8',

    using_frontend_proxy => 1,

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header                      => 0,    # Send X-Catalyst header

    recaptcha => {
        pub_key  => $ENV{RECAPTCHA_PUBKEY},
        priv_key => $ENV{RECAPTCHA_PRIVKEY},
    },
);

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

VotoLegal - Catalyst based application

=head1 SYNOPSIS

    script/votolegal_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<VotoLegal::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
