package VotoLegal::Worker;
use Moose::Role;

requires 'exec_item';
requires 'listen_queue';
requires 'run_once';

has timer => (
    is       => "ro",
	isa 	 => "Int",
    required => 1,
);

1;

