use strict;
use warnings FATAL => 'all';
use 5.014;
package NetObj::IPv4Network;

# ABSTRACT: represent an IPv4 network

use Moo;
use Carp;
use NetObj::IPv4Address;

sub is_valid {
    my ($net) = @_;
    croak __PACKAGE__ . '::is_valid is a class method only'
    if ref($net) eq __PACKAGE__;

    my ($ip, $cidr) = split(qr{/}, $net, 2);
    return !! (
        NetObj::IPv4Address::is_valid($ip)
            and ($cidr =~ m{\A \d+ \z}xms)
            and ($cidr >= 0)
            and ($cidr <=32)
    );
}

1;

__END__

=head1 SYNOPSIS

  use NetObj::IPv4Network;

  # constructor
  my $net1 = NetObj::IPv4Network->new('192.168.0.0/16');

=head1 DESCRIPTION

NetObj::IPv4Network represents IPv4 networks (subnets).

NetObj::IPv4Network is implemented as a Moose style object class (using Moo).

=method is_valid

The class method C<NetObj::IPv4Network::is_valid> tests for the validity of an
IPv4 subnet representation.  Only CIDR notation is accepted.

If called on an object, it throws an exception. Otherwise it just returns true
or false indicating validity.
