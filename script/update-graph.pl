#!/usr/bin/env perl
use strict;
BEGIN { $ENV{HARNESS_ACTIVE} = 1; }
use utf8;
use Test::More;
use lib 'lib';
use lib 't/lib';

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

my $res = $schema->resultset('FsmState')->_draw_machine( class => 'payment' );

use DDP;
p $res;
exit;
