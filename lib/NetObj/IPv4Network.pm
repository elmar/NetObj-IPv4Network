use strict;
use warnings FATAL => 'all';
use 5.014;
package NetObj::IPv4Network;

# ABSTRACT: represent an IPv4 network

use Moo;
use Carp;
use NetObj::IPv4Address;

sub _to_binary_and_cidr {
    my ($net) = @_;

    my ($ip, $mask) = split(qr{/}, $net, 2);

    # verify the IP address part (and convert to binary)
    return unless NetObj::IPv4Address::is_valid($ip);
    $ip = NetObj::IPv4Address->new($ip)->binary();

    # check whether $mask is already a CIDR specification
    if ($mask =~ m{\A \d+ \z}xms) {
        return unless (($mask >= 0) and ($mask <= 32));
    }
    else {
        # check for valid netmask
        return unless NetObj::IPv4Address::is_valid($mask);
        $mask = NetObj::IPv4Address->new($mask)->binary();
        ($mask) = unpack('B32', $mask);
        return unless ($mask =~ m{\A (1*) 0* \z}xms);
        $mask = length($1);
    }
    # $mask now contains the CIDR length of bits

    # mask the IP address to the CIDR length to get the network address
    ($ip) = unpack('B32', $ip);
    $ip = substr($ip, 0, $mask) . '0' x (32 - $mask);
    $ip = pack('B32', $ip);

    return {binary => $ip, cidr => $mask};
}

sub is_valid {
    my ($net) = @_;
    croak __PACKAGE__ . '::is_valid is a class method only'
    if ref($net) eq __PACKAGE__;

    return !! _to_binary_and_cidr($net);
}

has binary => ( is => 'ro' );
has cidr   => ( is => 'ro' );

sub BUILDARGS {
    my ($class, $net, @args) = @_;
    croak 'no IPv4 subnet given' unless defined($net);
    croak 'too many arguments in constructor for ' . __PACKAGE__ if @args;

    if (ref($net) eq __PACKAGE__) {
        return {
            binary => $net->binary(),
            cidr   => $net->cidr(),
        };
    }

    my $params = _to_binary_and_cidr($net);
    croak 'invalid IPv4 subnet' unless $params;
    return $params;
};

1;

__END__

=head1 SYNOPSIS

  use NetObj::IPv4Network;

  # constructor
  my $net1 = NetObj::IPv4Network->new('192.168.0.0/16');
  my $net2 = NetObj::IPv4Network->new('192.168.0.0/255.255.0.0');

  # cloning
  my $net3 = NetObj::IPv4Network->new($net1);

  # test validity
  NetObj::IPv4Network::is_valid('192.168.0.0/16'); # true
  NetObj::IPv4Network::is_valid('345.123.0.25/24'); # false

=head1 DESCRIPTION

NetObj::IPv4Network represents IPv4 networks (subnets).

NetObj::IPv4Network is implemented as a Moose style object class (using Moo).

=method is_valid

The class method C<NetObj::IPv4Network::is_valid> tests for the validity of an
IPv4 subnet representation.  Either CIDR notation or specifying a netmask is
accepted.

If called on an object, it throws an exception. Otherwise it just returns true
or false indicating validity.

=method new

The constructor expects one argument representing a valid IPv4 subnet.  CIDR or netmask notation are supported as in the C<is_valid> class method.

Cloning of an existing C<NetObj::IPv4Network> is supported.

The constructor throws an exception for invalid arguments.

=method binary

The C<binary> method returns the raw 4 bytes of the subnet's IPv4 address.

=method cidr

The C<cidr> method returns the number of bits used for the network part of the
IPv4 address.

=for Pod::Coverage
BUILDARGS -- internal method
