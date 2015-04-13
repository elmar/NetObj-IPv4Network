use strict;
use warnings FATAL => 'all';
use 5.014;
package NetObj::IPv4Network;

# ABSTRACT: represent an IPv4 network

use Moo;

1;

__END__

=head1 SYNOPSIS

  use NetObj::IPv4Network;

  # constructor
  my $net1 = NetObj::IPv4Network->new('192.168.0.0/16');

=head1 DESCRIPTION

NetObj::IPv4Network represents IPv4 networks (subnets).

NetObj::IPv4Network is implemented as a Moose style object class (using Moo).
