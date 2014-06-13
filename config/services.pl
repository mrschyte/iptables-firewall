#!/usr/bin/perl

package firewall;
use strict;

%firewall::services = (
	ssh					=> { source => "external", protocol => "tcp", port => "22" },
#	http				=> { source => "external", protocol => "tcp", port => "80" },
	bittorrent	=> { source => "external", protocol => "tcp", port => "10000:11000" },
);

return 1;
