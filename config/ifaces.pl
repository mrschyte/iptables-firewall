#!/usr/bin/perl

package firewall;
use strict;

%firewall::interfaces = (
	internal		=> [ 'lo', 'br0', 'eth0', 'eth1', 'ath0' ],
	external		=> [ 'ppp0' ],
	loopback		=> [ 'lo' ],
	bridge			=> [ 'br0' ],
	masquerade	=> [ 'br0' ]
);

return 1;
