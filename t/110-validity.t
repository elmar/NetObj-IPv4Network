#!perl
use strict;
use warnings FATAL => 'all';
use 5.014;

BEGIN { chdir 't' if -d 't'; }
use lib '../lib';

use Test::More; END { done_testing; }
use Test::Exception;

use NetObj::IPv4Network;

for my $netaddr (
    '0.0.0.0/0',       # extreme ends
    '0.0.0.0/32',
    '255.255.255.255/0',
    '255.255.255.255/32',
    '192.168.0.0/16',  # typical
    '192.168.128.0/20',
    '192.168.5.10/16', # IP address within range
) {
    ok(
        NetObj::IPv4Network::is_valid($netaddr),
        "$netaddr is a valid IPv4 subnet",
    );
}

# netmask notation
my @netmask_list = ();
for my $m (qw( 128 192 224 240 248 252 254 255 )) {
    push(@netmask_list, ( "${m}.0.0.0", "255.${m}.0.0", "255.255.${m}.0", "255.255.255.${m}"));
}
for my $netmask ( sort @netmask_list ) {
    my $net = "128.0.0.0/${netmask}";
    ok(
        NetObj::IPv4Network::is_valid("${net}"),
        "${net} is a valid IPv4 subnet",
    );
}

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
    ok(
        ! NetObj::IPv4Network::is_valid($netaddr),
        "$netaddr is not a valid IPv4 subnet",
    );
}

# make sure is_valid is a class method only
throws_ok(
    sub {
        NetObj::IPv4Network->new('192.168.0.0/16')->is_valid();
    },
    qr{class method},
    'NetObj::IPv4Network is a class method only',
);

