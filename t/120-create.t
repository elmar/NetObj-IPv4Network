#!perl
use strict;
use warnings FATAL => 'all';
use 5.014;

BEGIN { chdir 't' if -d 't'; }
use lib '../lib';

use Test::More; END { done_testing; }
use Test::Exception;

use NetObj::IPv4Network;

my %valid_nets = (
    '0.0.0.0/0'          => [ "\x00\x00\x00\x00", 0 ],
    '0.0.0.0/32'         => [ "\x00\x00\x00\x00", 32 ],
    '255.255.255.255/0'  => [ "\x00\x00\x00\x00", 0 ],
    '255.255.255.255/32' => [ "\xff\xff\xff\xff", 32 ],
    '192.168.5.34/24'    => [ "\xc0\xa8\x05\x00", 24 ],
);
for my $netaddr (keys %valid_nets) {
    my $net = NetObj::IPv4Network->new($netaddr);
    is(ref($net), 'NetObj::IPv4Network', "generate object for $netaddr");
    is($net->binary(), $valid_nets{$netaddr}[0], "correct IP for $netaddr");
    is($net->cidr(), $valid_nets{$netaddr}[1], "correct subnet length for $netaddr");
}

# cloning is valid
my $net1 = NetObj::IPv4Network->new('192.168.5.34/5');
my $net2 = NetObj::IPv4Network->new($net1);
is(ref($net2), 'NetObj::IPv4Network', 'clone a NetObj::IPv4Network object');
is($net1->binary(), $net2->binary(), 'clone has the same network address');
is($net1->cidr(), $net2->cidr(), 'clone has the same CIDR length');

# invalid
for my $netaddr (
    '256.1.1.1/16',  # each byte only up to 255
    '1.256.1.1/16',
    '1.1.256.1/16',
    '1.1..1256/16',
    '1.1.1.127/33',  # netmask CIDR only up to 32
    'm.n.o.p/16',    # only numeric
    '127.0.0.1/q',
) {
    throws_ok(
        sub { NetObj::IPv4Network->new($netaddr); STDERR->say('bar'); },
        qr{invalid IPv4 subnet},
        "$netaddr is not a valid IPv4 subnet",
    );
}

# bad number of arguments in the constructor
throws_ok(
    sub { NetObj::IPv4Network->new() },
    qr{no IPv4 subnet given},
    'must provide an IPv4 subnet specification',
);

throws_ok(
    sub { NetObj::IPv4Network->new('foo', 'bar') },
    qr{too many arguments},
    'only one IPv4 subnet allowed in constructor',
);
