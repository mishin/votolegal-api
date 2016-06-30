package VotoLegal::Payment;
use common::sense;
use Moose::Role;

requires 'tokenize_credit_card';
requires 'do_authorization';
requires 'do_capture';

1;
