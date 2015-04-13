#!perl
use strict;
use warnings FATAL => 'all';
use 5.014;

BEGIN { chdir 't' if -d 't'; }
use lib '../lib';

use Test::More; END { done_testing; }

BEGIN { use_ok('NetObj::IPv4Network'); }

is(
    ref(NetObj::IPv4Network->new('192.168.0.0/16')),
    'NetObj::IPv4Network',
    'NetObj::IPv4Network must be a class',
);
