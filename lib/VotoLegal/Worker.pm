package VotoLegal::Worker;
use Moose::Role;

requires 'exec_item';
requires 'listen_queue';
requires 'run_once';

1;

